import Foundation

public struct DefaultDiarizer: DiarizerProtocol {
    private let config: SherpaConfig
    private let audioProcessor: AudioProcessorProtocol
    private let embeddingExtractor: EmbeddingExtractorProtocol
    private let speakerMatcher: SpeakerMatcherProtocol
    
    public init(
        config: SherpaConfig,
        audioProcessor: AudioProcessorProtocol,
        embeddingExtractor: EmbeddingExtractorProtocol,
        speakerMatcher: SpeakerMatcherProtocol
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
