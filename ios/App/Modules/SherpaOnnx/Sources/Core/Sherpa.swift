import Foundation

public struct Sherpa {
    private let config: SherpaConfig
    private let audioProcessor: AudioProcessorProtocol
    private let embeddingExtractor: EmbeddingExtractorProtocol
    private let speakerMatcher: SpeakerMatcherProtocol
    private let diarizer: DiarizerProtocol
    private let languageDetector: LanguageDetectionProtocol?
    private let speechRecognizer: SpeechRecognitionProtocol?
    
    public init(
        config: SherpaConfig,
        audioProcessor: AudioProcessorProtocol? = nil,
        embeddingExtractor: EmbeddingExtractorProtocol? = nil,
        speakerMatcher: SpeakerMatcherProtocol? = nil,
        diarizer: DiarizerProtocol? = nil,
        languageDetector: LanguageDetectionProtocol? = nil,
        speechRecognizer: SpeechRecognitionProtocol? = nil
    ) {
        self.config = config
        self.audioProcessor = audioProcessor ?? DefaultAudioProcessor()
        self.embeddingExtractor = embeddingExtractor ?? DefaultEmbeddingExtractor(config: config)
        self.speakerMatcher = speakerMatcher ?? DefaultSpeakerMatcher(threshold: config.identityThreshold)
        self.diarizer = diarizer ?? DefaultDiarizer(
            config: config,
            audioProcessor: self.audioProcessor,
            embeddingExtractor: self.embeddingExtractor,
            speakerMatcher: self.speakerMatcher
        )
        
        if let langConfig = config.languageDetectionConfig {
            self.languageDetector = languageDetector ?? DefaultLanguageDetector(
                config: langConfig,
                audioProcessor: self.audioProcessor
            )
        } else {
            self.languageDetector = languageDetector
        }
        
        if !config.speechRecognitionConfigs.isEmpty {
            self.speechRecognizer = speechRecognizer ?? DefaultSpeechRecognizer(
                configs: config.speechRecognitionConfigs,
                audioProcessor: self.audioProcessor
            )
        } else {
            self.speechRecognizer = speechRecognizer
        }
    }
    
    public func extractEmbedding(from audioURL: URL) async throws -> [Float]? {
        let audio = try await audioProcessor.loadAudio(from: audioURL)
        let processedAudio = await audioProcessor.resample(audio, to: 16000)
        return await embeddingExtractor.extract(from: processedAudio)
    }
    
    public func diarize(
        audioURL: URL,
        numSpeakers: Int? = nil,
        knownSpeakers: [SpeakerEmbedding] = []
    ) async throws -> [DiarizationSegment] {
        let audio = try await audioProcessor.loadAudio(from: audioURL)
        
        return try await diarizer.diarize(
            audio: audio,
            numSpeakers: numSpeakers,
            knownSpeakers: knownSpeakers
        )
    }
    
    public func detectLanguage(from audioURL: URL) async throws -> LanguageDetectionResult {
        guard let detector = languageDetector else {
            throw SherpaError.configurationError("Language detection not configured")
        }
        return try await detector.detectLanguage(from: audioURL)
    }
    
    public func detectLanguage(from audioData: AudioData) async -> LanguageDetectionResult {
        guard let detector = languageDetector else {
            return LanguageDetectionResult(language: "unknown")
        }
        return await detector.detectLanguage(from: audioData)
    }
    
    public func transcribe(
        audioURL: URL,
        autoDetectLanguage: Bool = true
    ) async throws -> SpeechRecognitionResult {
        guard let recognizer = speechRecognizer else {
            throw SherpaError.configurationError("Speech recognition not configured")
        }
        
        var language: String? = nil
        
        if autoDetectLanguage, let detector = languageDetector {
            let detectionResult = try await detector.detectLanguage(from: audioURL)
            language = detectionResult.language
        }
        
        return try await recognizer.transcribe(audioURL: audioURL, language: language)
    }
    
    public func transcribe(
        audioData: AudioData,
        autoDetectLanguage: Bool = true
    ) async -> SpeechRecognitionResult {
        guard let recognizer = speechRecognizer else {
            return SpeechRecognitionResult(text: "", language: "unknown", segments: [])
        }
        
        var language: String? = nil
        
        if autoDetectLanguage, let detector = languageDetector {
            let detectionResult = await detector.detectLanguage(from: audioData)
            language = detectionResult.language
        }
        
        return await recognizer.transcribe(audioData: audioData, language: language)
    }
}
