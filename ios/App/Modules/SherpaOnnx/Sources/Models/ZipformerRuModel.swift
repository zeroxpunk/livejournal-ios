import Foundation

public struct ZipformerRuModel: Sendable {
    public let encoderResourceName = "zipformer-ru-encoder.int8"
    public let decoderResourceName = "zipformer-ru-decoder.int8"
    public let joinerResourceName = "zipformer-ru-joiner.int8"
    public let tokensResourceName = "zipformer-ru-tokens"
    public let tokensFileExtension = "txt"
    public let onnxFileExtension = "onnx"
    
    public init() {}
    
    public var encoderPath: String? {
        Bundle.main.path(forResource: encoderResourceName, ofType: onnxFileExtension)
    }
    
    public var decoderPath: String? {
        Bundle.main.path(forResource: decoderResourceName, ofType: onnxFileExtension)
    }
    
    public var tokensPath: String? {
        Bundle.main.path(forResource: tokensResourceName, ofType: tokensFileExtension)
    }
    
    public var joinerPath: String? {
        Bundle.main.path(forResource: joinerResourceName, ofType: onnxFileExtension)
    }
    
    public var encoderURL: URL? {
        Bundle.main.url(forResource: encoderResourceName, withExtension: onnxFileExtension)
    }
    
    public var decoderURL: URL? {
        Bundle.main.url(forResource: decoderResourceName, withExtension: onnxFileExtension)
    }
    
    public var joinerURL: URL? {
        Bundle.main.url(forResource: joinerResourceName, withExtension: onnxFileExtension)
    }
    
    public var tokensURL: URL? {
        Bundle.main.url(forResource: tokensResourceName, withExtension: tokensFileExtension)
    }
}
