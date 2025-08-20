import Foundation

final class DefaultSpeechRecognizer: SpeechRecognitionProtocol, @unchecked Sendable {
    private let configs: [String: SpeechRecognitionConfig]
    private let audioProcessor: AudioProcessorProtocol
    private var recognizers: [String: SherpaOnnxOfflineRecognizer] = [:]
    
    init(configs: [String: SpeechRecognitionConfig], audioProcessor: AudioProcessorProtocol? = nil) {
        self.configs = configs
        self.audioProcessor = audioProcessor ?? DefaultAudioProcessor()
        setupRecognizers()
    }
    
    private func setupRecognizers() {
        for (language, config) in configs {
            if let recognizer = createRecognizer(for: config) {
                recognizers[language] = recognizer
            }
        }
    }
    
    private func createRecognizer(for config: SpeechRecognitionConfig) -> SherpaOnnxOfflineRecognizer? {
        let modelConfig: SherpaOnnxOfflineModelConfig
        
        if config.modelType == "whisper" {
            let whisperConfig = sherpaOnnxOfflineWhisperModelConfig(
                encoder: config.encoderPath ?? "",
                decoder: config.decoderPath ?? "",
                language: ""
            )
            modelConfig = sherpaOnnxOfflineModelConfig(
                tokens: config.tokensPath,
                whisper: whisperConfig,
                numThreads: config.numThreads,
                provider: "cpu"
            )
        } else if config.modelType == "paraformer" {
            let paraformerConfig = sherpaOnnxOfflineParaformerModelConfig(
                model: config.modelPath
            )
            modelConfig = sherpaOnnxOfflineModelConfig(
                tokens: config.tokensPath,
                paraformer: paraformerConfig,
                numThreads: config.numThreads,
                provider: "cpu"
            )
        } else if config.modelType == "zipformer" {
            let transducerConfig = sherpaOnnxOfflineTransducerModelConfig(
                encoder: config.encoderPath ?? "",
                decoder: config.decoderPath  ?? "",
                joiner: config.joinerPath  ?? ""
            )
            modelConfig = sherpaOnnxOfflineModelConfig(
                tokens: config.tokensPath,
                transducer: transducerConfig,
                debug: 0,
                modelType: "zipformer"
            )
        } else {
            return nil
        }
        
        let featureConfig = sherpaOnnxFeatureConfig(
            sampleRate: config.sampleRate,
            featureDim: config.featureDim
        )
        
        var recognizerConfig = sherpaOnnxOfflineRecognizerConfig(
            featConfig: featureConfig,
            modelConfig: modelConfig
        )
        
        return withUnsafePointer(to: &recognizerConfig) { configPtr in
            SherpaOnnxOfflineRecognizer(config: configPtr)
        }
    }
    
    func transcribe(audioData: AudioData, language: String?) async -> SpeechRecognitionResult {
        let lang = language ?? configs.keys.first ?? "en"
        
        guard let recognizer = recognizers[lang] else {
            return SpeechRecognitionResult(text: "", language: lang, segments: [])
        }
        
        let processedAudio = await audioProcessor.resample(audioData, to: 16000)
        let result = recognizer.decode(samples: processedAudio.samples, sampleRate: 16000)
        
        return SpeechRecognitionResult(
            text: result.text,
            language: lang,
            segments: []
        )
    }
    
    func transcribe(audioURL: URL, language: String?) async throws -> SpeechRecognitionResult {
        let audio = try await audioProcessor.loadAudio(from: audioURL)
        return await transcribe(audioData: audio, language: language)
    }
}
