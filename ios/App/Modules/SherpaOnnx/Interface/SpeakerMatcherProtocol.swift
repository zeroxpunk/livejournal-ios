import Foundation

public protocol SpeakerMatcherProtocol: Sendable {
    func match(embedding: [Float], against knownSpeakers: [SpeakerEmbedding]) async -> String?
}
