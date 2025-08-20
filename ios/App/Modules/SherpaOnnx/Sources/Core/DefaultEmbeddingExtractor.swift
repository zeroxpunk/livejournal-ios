import Foundation

public struct DefaultEmbeddingExtractor: EmbeddingExtractorProtocol {
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
