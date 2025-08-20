import AVFoundation
import Foundation

public struct AudioData {
    public let samples: [Float]
    public let sampleRate: Int
    
    public init(samples: [Float], sampleRate: Int) {
        self.samples = samples
        self.sampleRate = sampleRate
    }
}

public struct SpeakerEmbedding {
    public let id: String
    public let name: String
    public let embedding: [Float]
    
    public init(id: String = UUID().uuidString, name: String, embedding: [Float]) {
        self.id = id
        self.name = name
        self.embedding = embedding
    }
}

public struct DiarizationSegment {
    public let start: Float
    public let end: Float
    public let speakerId: Int
    public let speakerName: String?
    
    public init(start: Float, end: Float, speakerId: Int, speakerName: String? = nil) {
        self.start = start
        self.end = end
        self.speakerId = speakerId
        self.speakerName = speakerName
    }
}

public struct SherpaConfig {
    public let segmentationModelPath: String
    public let embeddingModelPath: String
    public let numThreads: Int
    public let provider: String
    public let identityThreshold: Float
    
    public init(
        segmentationModelPath: String,
        embeddingModelPath: String,
        numThreads: Int = 1,
        provider: String = "cpu",
        identityThreshold: Float = 0.4
    ) {
        self.segmentationModelPath = segmentationModelPath
        self.embeddingModelPath = embeddingModelPath
        self.numThreads = numThreads
        self.provider = provider
        self.identityThreshold = identityThreshold
    }
}

public enum SherpaError: Error {
    case invalidAudioFormat
    case modelInitializationFailed
    case processingFailed
    case fileNotFound
    case conversionFailed
}


public protocol AudioProcessor {
    
    func loadAudio(from url: URL) async throws -> AudioData
    
    
    func resample(_ audio: AudioData, to targetSampleRate: Int) async -> AudioData
}


public protocol EmbeddingExtractor {
    
    func extract(from audio: AudioData) async -> [Float]?
}


public protocol SpeakerMatcher {
    
    func match(embedding: [Float], against knownSpeakers: [SpeakerEmbedding]) async -> String?
}


public protocol Diarizer {
    
    func diarize(audio: AudioData, numSpeakers: Int?, knownSpeakers: [SpeakerEmbedding]) async throws -> [DiarizationSegment]
}

public struct DefaultAudioProcessor: AudioProcessor {
    public init() {}
    
    public func loadAudio(from url: URL) async throws -> AudioData {
        let audioFile = try AVAudioFile(forReading: url)
        let format = audioFile.processingFormat
        let frameCount = AVAudioFrameCount(audioFile.length)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw SherpaError.invalidAudioFormat
        }
        
        try audioFile.read(into: buffer)
        
        let samples = await extractMonoSamples(from: buffer)
        return AudioData(samples: samples, sampleRate: Int(format.sampleRate))
    }
    
    public func resample(_ audio: AudioData, to targetSampleRate: Int) async -> AudioData {
        if audio.sampleRate == targetSampleRate {
            return audio
        }
        
        let ratio = Double(targetSampleRate) / Double(audio.sampleRate)
        let outputLength = Int(Double(audio.samples.count) * ratio)
        var resampled = [Float](repeating: 0, count: outputLength)
        
        for i in 0..<outputLength {
            let sourceIndex = Double(i) / ratio
            let index = Int(sourceIndex)
            let fraction = Float(sourceIndex - Double(index))
            
            if index < audio.samples.count - 1 {
                resampled[i] = audio.samples[index] * (1 - fraction) + audio.samples[index + 1] * fraction
            } else if index < audio.samples.count {
                resampled[i] = audio.samples[index]
            }
        }
        
        return AudioData(samples: resampled, sampleRate: targetSampleRate)
    }
    
    private func extractMonoSamples(from buffer: AVAudioPCMBuffer) async -> [Float] {
        let format = buffer.format
        let frameLength = Int(buffer.frameLength)
        
        guard let floatChannelData = buffer.floatChannelData else {
            return []
        }
        
        var samples: [Float] = []
        
        if format.channelCount == 1 {
            for i in 0..<frameLength {
                samples.append(floatChannelData[0][i])
            }
        } else {
            for i in 0..<frameLength {
                var sum: Float = 0
                for channel in 0..<Int(format.channelCount) {
                    sum += floatChannelData[channel][i]
                }
                samples.append(sum / Float(format.channelCount))
            }
        }
        
        return samples
    }
}

public struct DefaultEmbeddingExtractor: EmbeddingExtractor {
    private let config: SherpaConfig
    
    public init(config: SherpaConfig) {
        self.config = config
    }
    
    public func extract(from audio: AudioData) async -> [Float]? {
        var extractorConfig = sherpaOnnxSpeakerEmbeddingExtractorConfig(
            model: config.embeddingModelPath,
            numThreads: config.numThreads,
            provider: config.provider
        )
        
        let extractor = SherpaOnnxSpeakerEmbeddingExtractorWrapper(config: &extractorConfig)
        return extractor.compute(samples: audio.samples, sampleRate: audio.sampleRate)
    }
}

public struct DefaultSpeakerMatcher: SpeakerMatcher {
    private let threshold: Float
    
    public init(threshold: Float) {
        self.threshold = threshold
    }
    
    public func match(embedding: [Float], against knownSpeakers: [SpeakerEmbedding]) async -> String? {
        var bestMatch: (name: String, similarity: Float)?
        
        for speaker in knownSpeakers {
            let similarity = cosineSimilarity(embedding, speaker.embedding)
            
            if similarity > threshold {
                if bestMatch == nil || similarity > bestMatch!.similarity {
                    bestMatch = (name: speaker.name, similarity: similarity)
                }
            }
        }
        
        return bestMatch?.name
    }
    
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count && a.count > 0 else { return 0 }
        
        var dotProduct: Float = 0
        var normA: Float = 0
        var normB: Float = 0
        
        for i in 0..<a.count {
            dotProduct += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }
        
        let denominator = sqrt(normA) * sqrt(normB)
        return denominator > 0 ? dotProduct / denominator : 0
    }
}

public struct DefaultDiarizer: Diarizer {
    private let config: SherpaConfig
    private let audioProcessor: AudioProcessor
    private let embeddingExtractor: EmbeddingExtractor
    private let speakerMatcher: SpeakerMatcher
    
    public init(
        config: SherpaConfig,
        audioProcessor: AudioProcessor,
        embeddingExtractor: EmbeddingExtractor,
        speakerMatcher: SpeakerMatcher
    ) {
        self.config = config
        self.audioProcessor = audioProcessor
        self.embeddingExtractor = embeddingExtractor
        self.speakerMatcher = speakerMatcher
    }
    
    public func diarize(audio: AudioData, numSpeakers: Int?, knownSpeakers: [SpeakerEmbedding]) async throws -> [DiarizationSegment] {
        let processedAudio = await audioProcessor.resample(audio, to: 16000)
        
        var diarizationConfig = sherpaOnnxOfflineSpeakerDiarizationConfig(
            segmentation: sherpaOnnxOfflineSpeakerSegmentationModelConfig(
                pyannote: sherpaOnnxOfflineSpeakerSegmentationPyannoteModelConfig(
                    model: config.segmentationModelPath
                )
            ),
            embedding: sherpaOnnxSpeakerEmbeddingExtractorConfig(
                model: config.embeddingModelPath,
                numThreads: config.numThreads,
                provider: config.provider
            ),
            clustering: sherpaOnnxFastClusteringConfig(
                numClusters: numSpeakers ?? -1
            )
        )
        
        let diarizer = SherpaOnnxOfflineSpeakerDiarizationWrapper(config: &diarizationConfig)
        let rawSegments = diarizer.process(samples: processedAudio.samples)
        
        var segments = rawSegments.map { segment in
            DiarizationSegment(
                start: segment.start,
                end: segment.end,
                speakerId: segment.speaker
            )
        }
        
        if !knownSpeakers.isEmpty {
            segments = await matchSegmentsWithKnownSpeakers(
                segments: segments,
                audio: audio,
                knownSpeakers: knownSpeakers
            )
        }
        
        return segments
    }
    
    private func matchSegmentsWithKnownSpeakers(
        segments: [DiarizationSegment],
        audio: AudioData,
        knownSpeakers: [SpeakerEmbedding]
    ) async -> [DiarizationSegment] {
        var speakerSegments: [Int: [DiarizationSegment]] = [:]
        for segment in segments {
            speakerSegments[segment.speakerId, default: []].append(segment)
        }
        
        var speakerMatches: [Int: String] = [:]
        
        for (speakerId, speakerSegs) in speakerSegments {
            guard let longestSegment = speakerSegs
                .max(by: { ($0.end - $0.start) < ($1.end - $1.start) }) else {
                continue
            }
            
            let startSample = Int(longestSegment.start * Float(audio.sampleRate))
            let endSample = Int(longestSegment.end * Float(audio.sampleRate))
            let segmentSamples = Array(audio.samples[min(startSample, audio.samples.count-1)..<min(endSample, audio.samples.count)])
            
            let segmentAudio = AudioData(samples: segmentSamples, sampleRate: audio.sampleRate)
            let processedAudio = await audioProcessor.resample(segmentAudio, to: 16000)
            
            if let embedding = await embeddingExtractor.extract(from: processedAudio),
               let matchedName = await speakerMatcher.match(
                embedding: embedding,
                against: knownSpeakers
               ) {
                speakerMatches[speakerId] = matchedName
            }
        }
        
        return segments.map { segment in
            DiarizationSegment(
                start: segment.start,
                end: segment.end,
                speakerId: segment.speakerId,
                speakerName: speakerMatches[segment.speakerId]
            )
        }
    }
}

public struct Sherpa {
    private let config: SherpaConfig
    private let audioProcessor: AudioProcessor
    private let embeddingExtractor: EmbeddingExtractor
    private let speakerMatcher: SpeakerMatcher
    private let diarizer: Diarizer
    
    public init(
        config: SherpaConfig,
        audioProcessor: AudioProcessor? = nil,
        embeddingExtractor: EmbeddingExtractor? = nil,
        speakerMatcher: SpeakerMatcher? = nil,
        diarizer: Diarizer? = nil
    ) {
        self.config = config
        self.audioProcessor = audioProcessor ?? DefaultAudioProcessor()
        self.embeddingExtractor = embeddingExtractor ?? DefaultEmbeddingExtractor(config: config)
        self.speakerMatcher = speakerMatcher ?? DefaultSpeakerMatcher(threshold: config.identityThreshold)
        self.diarizer = diarizer ?? DefaultDiarizer(
            config: config,
            audioProcessor: self.audioProcessor,
            embeddingExtractor: self.embeddingExtractor,
            speakerMatcher: self.speakerMatcher
        )
    }
    
    public func extractEmbedding(from audioURL: URL) async throws -> [Float]? {
        let audio = try await audioProcessor.loadAudio(from: audioURL)
        let processedAudio = await audioProcessor.resample(audio, to: 16000)
        return await embeddingExtractor.extract(from: processedAudio)
    }
    
    public func diarize(
        audioURL: URL,
        numSpeakers: Int? = nil,
        knownSpeakers: [SpeakerEmbedding] = []
    ) async throws -> [DiarizationSegment] {
        let audio = try await audioProcessor.loadAudio(from: audioURL)
        
        return try await diarizer.diarize(
            audio: audio,
            numSpeakers: numSpeakers,
            knownSpeakers: knownSpeakers
        )
    }
}
