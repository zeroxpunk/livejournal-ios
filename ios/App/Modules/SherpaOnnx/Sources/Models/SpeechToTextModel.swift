import Foundation

public enum SpeechToTextModel {
    public static func createConfig(
        for language: String,
        numThreads: Int = 1
    ) -> SpeechRecognitionConfig? {
        if language.lowercased() == "ru" {
            let model = ZipformerRuModel()
            
            guard let encoderPath = model.encoderPath,
                  let decoderPath = model.decoderPath,
                  let joinerPath = model.joinerPath,
                  let tokensPath = model.tokensPath else {
                return nil
            }
            
            return SpeechRecognitionConfig(
                modelPath: encoderPath,
                tokensPath: tokensPath,
                encoderPath: encoderPath,
                decoderPath: decoderPath,
                joinerPath: joinerPath,
                modelType: "zipformer",
                sampleRate: 16000,
                featureDim: 80,
                numThreads: numThreads
            )
        } else {
            let model = WhisperTinyModel()
            
            guard let encoderPath = model.encoderPath,
                  let decoderPath = model.decoderPath,
                  let tokensPath = model.tokensPath else {
                return nil
            }
            
            return SpeechRecognitionConfig(
                modelPath: encoderPath,
                tokensPath: tokensPath,
                encoderPath: encoderPath,
                decoderPath: decoderPath,
                joinerPath: nil,
                modelType: "whisper",
                sampleRate: 16000,
                featureDim: 80,
                numThreads: numThreads
            )
        }
    }
}
