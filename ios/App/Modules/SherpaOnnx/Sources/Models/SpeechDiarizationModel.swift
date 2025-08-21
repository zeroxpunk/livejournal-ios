import Foundation

public struct SpeechDiarizationModel: Sendable {
    public let segmentationResourceName = "pyannote-segmentation"
    public let embeddingResourceName = "3dspeaker_speech_eres2net_base_sv_zh-cn_3dspeaker_16k"
    public let onnxFileExtension = "onnx"
    
    public init() {}
    
    public var segmentationPath: String? {
        Bundle.main.path(forResource: segmentationResourceName, ofType: onnxFileExtension)
    }
    
    public var embeddingPath: String? {
        Bundle.main.path(forResource: embeddingResourceName, ofType: onnxFileExtension)
    }
    
    public var segmentationURL: URL? {
        Bundle.main.url(forResource: segmentationResourceName, withExtension: onnxFileExtension)
    }
    
    public var embeddingURL: URL? {
        Bundle.main.url(forResource: embeddingResourceName, withExtension: onnxFileExtension)
    }
}

public extension SpeechDiarizationModel {
    static func createConfig(
        numThreads: Int = 1,
        provider: String = "cpu"
    ) -> SpeechDiarizationConfig? {
        let model = SpeechDiarizationModel()
        
        guard let segmentationPath = model.segmentationPath,
              let embeddingPath = model.embeddingPath else {
            return nil
        }
        
        return SpeechDiarizationConfig(
            segmentationModelPath: segmentationPath,
            embeddingModelPath: embeddingPath,
            numThreads: numThreads,
            provider: provider
        )
    }
}