import Foundation

public protocol LanguageDetectionProtocol: Sendable {
    func detectLanguage(from audioData: AudioData) async -> LanguageDetectionResult
    func detectLanguage(from audioURL: URL) async throws -> LanguageDetectionResult
}

public struct LanguageDetectionResult: Sendable {
    public let language: String
    
    public init(language: String) {
        self.language = language
    }
}
