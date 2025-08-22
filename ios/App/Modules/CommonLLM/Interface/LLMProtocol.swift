import Foundation

public protocol LLMProtocol: Sendable {
    func completions(messages: [Message]) async throws -> String
    func completionsStream(messages: [Message]) async throws -> AsyncThrowingStream<String, Error>
}
