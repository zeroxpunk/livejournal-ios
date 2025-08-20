import Foundation

public protocol DiarizerProtocol: Sendable {
    func diarize(audio: AudioData, numSpeakers: Int?, knownSpeakers: [SpeakerEmbedding]) async throws -> [DiarizationSegment]
}
