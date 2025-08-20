import Foundation

public protocol EmbeddingExtractorProtocol: Sendable {
    func extract(from audio: AudioData) async -> [Float]?
}
