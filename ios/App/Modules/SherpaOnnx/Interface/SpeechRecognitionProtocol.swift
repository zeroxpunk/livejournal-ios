import Foundation

public protocol SpeechRecognitionProtocol: Sendable {
    func transcribe(
        audioData: AudioData,
        language: String?
    ) async -> SpeechRecognitionResult
    
    func transcribe(
        audioURL: URL,
        language: String?
    ) async throws -> SpeechRecognitionResult
}

public struct SpeechRecognitionResult: Sendable {
    public let text: String
    public let language: String
    public let segments: [SpeechSegment]
    
    public init(text: String, language: String, segments: [SpeechSegment]) {
        self.text = text
        self.language = language
        self.segments = segments
    }
}

public struct SpeechSegment: Sendable {
    public let text: String
    public let startTime: Float
    public let endTime: Float
    
    public init(text: String, startTime: Float, endTime: Float) {
        self.text = text
        self.startTime = startTime
        self.endTime = endTime
    }
}
