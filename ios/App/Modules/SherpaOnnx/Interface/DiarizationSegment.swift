import Foundation

public struct DiarizationSegment: Sendable {
    public let start: Float
    public let end: Float
    public let speakerId: Int
    public let speakerName: String?
    
    public init(start: Float, end: Float, speakerId: Int, speakerName: String? = nil) {
        self.start = start
        self.end = end
        self.speakerId = speakerId
        self.speakerName = speakerName
    }
}
