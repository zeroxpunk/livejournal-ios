import Foundation

final class DefaultLanguageDetector: LanguageDetectionProtocol, @unchecked Sendable {
    private let config: LanguageDetectionConfig
    private let audioProcessor: AudioProcessorProtocol
    private var identifier: SherpaOnnxSpokenLanguageIdentification?
    
    init(config: LanguageDetectionConfig, audioProcessor: AudioProcessorProtocol? = nil) {
        self.config = config
        self.audioProcessor = audioProcessor ?? DefaultAudioProcessor()
        setupIdentifier()
    }
    
    private func setupIdentifier() {
        let whisperConfig = sherpaOnnxSpokenLanguageIdentificationWhisperConfig(
            encoder: config.whisperEncoderPath,
            decoder: config.whisperDecoderPath
        )
        var idConfig = sherpaOnnxSpokenLanguageIdentificationConfig(
            whisper: whisperConfig,
            numThreads: config.numThreads,
            debug: 0,
            provider: "cpu"
        )
        
        withUnsafePointer(to: &idConfig) { configPtr in
            identifier = SherpaOnnxSpokenLanguageIdentification(config: configPtr)
        }
    }
    
    func detectLanguage(from audioData: AudioData) async -> LanguageDetectionResult {
        guard let identifier = identifier else {
            return LanguageDetectionResult(language: "unknown")
        }
        
        let processedAudio = await audioProcessor.resample(audioData, to: 16000)
        let result = identifier.identify(samples: processedAudio.samples, sampleRate: 16000)
        
        return LanguageDetectionResult(language: result.language)
    }
    
    func detectLanguage(from audioURL: URL) async throws -> LanguageDetectionResult {
        let audio = try await audioProcessor.loadAudio(from: audioURL)
        return await detectLanguage(from: audio)
    }
}
