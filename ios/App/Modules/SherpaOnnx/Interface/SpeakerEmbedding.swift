import Foundation

public struct SpeakerEmbedding: Sendable, Codable {
    public let id: String
    public let name: String
    public let embedding: [Float]
    
    public init(id: String = UUID().uuidString, name: String, embedding: [Float]) {
        self.id = id
        self.name = name
        self.embedding = embedding
    }
}
