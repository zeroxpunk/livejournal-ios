import Foundation

public struct AudioData: Sendable {
    public let samples: [Float]
    public let sampleRate: Int
    
    public init(samples: [Float], sampleRate: Int) {
        self.samples = samples
        self.sampleRate = sampleRate
    }
}
