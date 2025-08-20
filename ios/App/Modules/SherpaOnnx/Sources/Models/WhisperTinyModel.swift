import Foundation

public struct WhisperTinyModel: Sendable {
    public let encoderResourceName = "whisper-tiny-encoder.int8"
    public let decoderResourceName = "whisper-tiny-decoder.int8"
    public let tokensResourceName = "whisper-tiny-tokens"
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
    
    public var encoderURL: URL? {
        Bundle.main.url(forResource: encoderResourceName, withExtension: onnxFileExtension)
    }
    
    public var decoderURL: URL? {
        Bundle.main.url(forResource: decoderResourceName, withExtension: onnxFileExtension)
    }
    
    public var tokensURL: URL? {
        Bundle.main.url(forResource: tokensResourceName, withExtension: tokensFileExtension)
    }
}
