import Foundation

public struct DefaultEmbeddingExtractor: EmbeddingExtractorProtocol {
    private let config: SherpaConfig
    
    public init(config: SherpaConfig) {
        self.config = config
    }
    
    public func extract(from audio: AudioData) async -> [Float]? {
        guard let diarizationConfig = config.speechDiarizationConfig else {
            return nil
        }
        
        var extractorConfig = sherpaOnnxSpeakerEmbeddingExtractorConfig(
            model: diarizationConfig.embeddingModelPath,
            numThreads: diarizationConfig.numThreads,
            provider: diarizationConfig.provider
        )
        
        let extractor = SherpaOnnxSpeakerEmbeddingExtractorWrapper(config: &extractorConfig)
        return extractor.compute(samples: audio.samples, sampleRate: audio.sampleRate)
    }
}
