import Foundation

public struct SherpaConfig: Sendable {
    public let segmentationModelPath: String
    public let embeddingModelPath: String
    public let numThreads: Int
    public let provider: String
    public let identityThreshold: Float
    
    public init(
        segmentationModelPath: String,
        embeddingModelPath: String,
        numThreads: Int = 1,
        provider: String = "cpu",
        identityThreshold: Float = 0.4
    ) {
        self.segmentationModelPath = segmentationModelPath
        self.embeddingModelPath = embeddingModelPath
        self.numThreads = numThreads
        self.provider = provider
        self.identityThreshold = identityThreshold
    }
}
