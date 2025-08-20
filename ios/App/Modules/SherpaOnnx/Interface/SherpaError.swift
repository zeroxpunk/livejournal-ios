import Foundation

public enum SherpaError: Error, Sendable {
    case invalidAudioFormat
    case modelInitializationFailed
    case processingFailed
    case fileNotFound
    case conversionFailed
    case configurationError(String)
}
