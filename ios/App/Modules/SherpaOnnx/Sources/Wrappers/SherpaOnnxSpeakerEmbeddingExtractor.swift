import Foundation

class SherpaOnnxSpeakerEmbeddingExtractorWrapper {
    let extractor: OpaquePointer!
    
    init(config: UnsafePointer<SherpaOnnxSpeakerEmbeddingExtractorConfig>!) {
        extractor = SherpaOnnxCreateSpeakerEmbeddingExtractor(config)
        if extractor == nil {
            print("Error: Failed to create SherpaOnnxSpeakerEmbeddingExtractor instance")
        }
    }
    
    deinit {
        if let extractor {
            SherpaOnnxDestroySpeakerEmbeddingExtractor(extractor)
        }
    }
    
    var dim: Int {
        return Int(SherpaOnnxSpeakerEmbeddingExtractorDim(extractor))
    }
    
    func createStream() -> OpaquePointer? {
        return SherpaOnnxSpeakerEmbeddingExtractorCreateStream(extractor)
    }
    
    func compute(samples: [Float], sampleRate: Int = 16000) -> [Float]? {
        guard !samples.isEmpty else {
            return nil
        }
        
        let stream = createStream()
        guard let stream = stream else {
            return nil
        }
        
        defer {
            SherpaOnnxDestroyOnlineStream(stream)
        }
        
        samples.withUnsafeBufferPointer { samplesPtr in
            guard let baseAddress = samplesPtr.baseAddress else {
                return 
            }
            SherpaOnnxOnlineStreamAcceptWaveform(stream, Int32(sampleRate), baseAddress, Int32(samples.count))
        }
        
        SherpaOnnxOnlineStreamInputFinished(stream)
        
        let isReady = SherpaOnnxSpeakerEmbeddingExtractorIsReady(extractor, stream)
        
        if isReady == 0 {
            return nil
        }
        
        let embeddingPtr = SherpaOnnxSpeakerEmbeddingExtractorComputeEmbedding(extractor, stream)
        guard let embeddingPtr = embeddingPtr else {
            return nil
        }
        
        defer {
            SherpaOnnxSpeakerEmbeddingExtractorDestroyEmbedding(embeddingPtr)
        }
        
        var embedding: [Float] = []
        let embeddingDim = self.dim
        
        for i in 0..<embeddingDim {
            embedding.append(embeddingPtr[i])
        }
        
        return embedding
    }
}
