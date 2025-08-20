import Foundation

public protocol AudioProcessorProtocol: Sendable {
    func loadAudio(from url: URL) async throws -> AudioData
    func resample(_ audio: AudioData, to targetSampleRate: Int) async -> AudioData
}
