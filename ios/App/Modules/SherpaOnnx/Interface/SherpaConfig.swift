import Foundation

public struct SherpaConfig: Sendable {
    public let speechDiarizationConfig: SpeechDiarizationConfig?
    public let numThreads: Int
    public let provider: String
    public let identityThreshold: Float
    public let languageDetectionConfig: LanguageDetectionConfig?
    public let speechRecognitionConfigs: [String: SpeechRecognitionConfig]
    
    public init(
        numThreads: Int = 1,
        provider: String = "cpu",
        identityThreshold: Float = 0.4,
        speechDiarizationConfig: SpeechDiarizationConfig? = nil,
        languageDetectionConfig: LanguageDetectionConfig? = nil,
        speechRecognitionConfigs: [String: SpeechRecognitionConfig] = [:]
    ) {
        self.numThreads = numThreads
        self.provider = provider
        self.identityThreshold = identityThreshold
        self.speechDiarizationConfig = speechDiarizationConfig ?? SpeechDiarizationModel.createConfig(numThreads: numThreads)
        self.languageDetectionConfig = languageDetectionConfig ?? LanguageDetectionModel.createConfig(numThreads: numThreads)
        self.speechRecognitionConfigs = speechRecognitionConfigs.isEmpty ? Self.defaultSpeechRecognitionConfigs(numThreads: numThreads) : speechRecognitionConfigs
    }
    
    private static func defaultSpeechRecognitionConfigs(numThreads: Int) -> [String: SpeechRecognitionConfig] {
        var configs: [String: SpeechRecognitionConfig] = [:]
        
        if let ruConfig = SpeechToTextModel.createConfig(for: "ru", numThreads: numThreads) {
            configs["ru"] = ruConfig
        }
        
        if let enConfig = SpeechToTextModel.createConfig(for: "en", numThreads: numThreads) {
            configs["en"] = enConfig
        }
        
        return configs
    }
}

public struct SpeechDiarizationConfig: Sendable {
    public let segmentationModelPath: String
    public let embeddingModelPath: String
    public let numThreads: Int
    public let provider: String
    
    public init(
        segmentationModelPath: String,
        embeddingModelPath: String,
        numThreads: Int = 1,
        provider: String = "cpu"
    ) {
        self.segmentationModelPath = segmentationModelPath
        self.embeddingModelPath = embeddingModelPath
        self.numThreads = numThreads
        self.provider = provider
    }
}

public struct LanguageDetectionConfig: Sendable {
    public let whisperModelPath: String
    public let whisperEncoderPath: String
    public let whisperDecoderPath: String
    public let numThreads: Int
    
    public init(
        whisperModelPath: String,
        whisperEncoderPath: String,
        whisperDecoderPath: String,
        numThreads: Int = 1
    ) {
        self.whisperModelPath = whisperModelPath
        self.whisperEncoderPath = whisperEncoderPath
        self.whisperDecoderPath = whisperDecoderPath
        self.numThreads = numThreads
    }
}

public struct SpeechRecognitionConfig: Sendable {
    public let modelPath: String
    public let tokensPath: String
    public let encoderPath: String?
    public let decoderPath: String?
    public let joinerPath: String?
    public let modelType: String
    public let sampleRate: Int
    public let featureDim: Int
    public let numThreads: Int
    
    public init(
        modelPath: String,
        tokensPath: String,
        encoderPath: String? = nil,
        decoderPath: String? = nil,
        joinerPath: String? = nil,
        modelType: String = "whisper",
        sampleRate: Int = 16000,
        featureDim: Int = 80,
        numThreads: Int = 1
    ) {
        self.modelPath = modelPath
        self.tokensPath = tokensPath
        self.encoderPath = encoderPath
        self.decoderPath = decoderPath
        self.joinerPath = joinerPath
        self.modelType = modelType
        self.sampleRate = sampleRate
        self.featureDim = featureDim
        self.numThreads = numThreads
    }
}
