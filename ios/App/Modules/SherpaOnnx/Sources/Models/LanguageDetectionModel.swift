import Foundation

public enum LanguageDetectionModel {
    public static let whisperTiny = WhisperTinyModel()
    
    public struct WhisperTinyModel: Sendable {
        public let encoderResourceName = "whisper-tiny-encoder.int8"
        public let decoderResourceName = "whisper-tiny-decoder.int8"
        public let fileExtension = "onnx"
        
        public var encoderPath: String? {
            Bundle.main.path(forResource: encoderResourceName, ofType: fileExtension)
        }
        
        public var decoderPath: String? {
            Bundle.main.path(forResource: decoderResourceName, ofType: fileExtension)
        }
        
        public var encoderURL: URL? {
            Bundle.main.url(forResource: encoderResourceName, withExtension: fileExtension)
        }
        
        public var decoderURL: URL? {
            Bundle.main.url(forResource: decoderResourceName, withExtension: fileExtension)
        }
        
        public func createConfig(numThreads: Int = 1) -> LanguageDetectionConfig? {
            guard let encoderPath = encoderPath,
                  let decoderPath = decoderPath else {
                return nil
            }
            
            return LanguageDetectionConfig(
                whisperModelPath: "",
                whisperEncoderPath: encoderPath,
                whisperDecoderPath: decoderPath,
                numThreads: numThreads
            )
        }
    }
}
