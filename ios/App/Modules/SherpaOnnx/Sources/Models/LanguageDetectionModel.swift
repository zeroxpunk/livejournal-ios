import Foundation

public enum LanguageDetectionModel {
    public static let defaultModel = WhisperTinyModel()
    
    public static func createConfig(with model: WhisperTinyModel = defaultModel, numThreads: Int = 1) -> LanguageDetectionConfig? {
        guard let encoderPath = model.encoderPath,
              let decoderPath = model.decoderPath else {
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