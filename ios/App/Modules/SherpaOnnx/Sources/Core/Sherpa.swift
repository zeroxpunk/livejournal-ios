import Foundation

public struct Sherpa {
    private let config: SherpaConfig
    private let audioProcessor: AudioProcessorProtocol
    private let embeddingExtractor: EmbeddingExtractorProtocol
    private let speakerMatcher: SpeakerMatcherProtocol
    private let diarizer: DiarizerProtocol
    
    public init(
        config: SherpaConfig,
        audioProcessor: AudioProcessorProtocol? = nil,
        embeddingExtractor: EmbeddingExtractorProtocol? = nil,
        speakerMatcher: SpeakerMatcherProtocol? = nil,
        diarizer: DiarizerProtocol? = nil
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
