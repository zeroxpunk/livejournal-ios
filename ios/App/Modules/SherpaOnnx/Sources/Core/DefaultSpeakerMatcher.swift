import Foundation

public struct DefaultSpeakerMatcher: SpeakerMatcherProtocol {
    private let threshold: Float
    
    public init(threshold: Float) {
        self.threshold = threshold
    }
    
    public func match(embedding: [Float], against knownSpeakers: [SpeakerEmbedding]) async -> String? {
        var bestMatch: (name: String, similarity: Float)?
        
        for speaker in knownSpeakers {
            let similarity = cosineSimilarity(embedding, speaker.embedding)
            
            if similarity > threshold {
                if bestMatch == nil || similarity > bestMatch!.similarity {
                    bestMatch = (name: speaker.name, similarity: similarity)
                }
            }
        }
        
        return bestMatch?.name
    }
    
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count && a.count > 0 else { return 0 }
        
        var dotProduct: Float = 0
        var normA: Float = 0
        var normB: Float = 0
        
        for i in 0..<a.count {
            dotProduct += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }
        
        let denominator = sqrt(normA) * sqrt(normB)
        return denominator > 0 ? dotProduct / denominator : 0
    }
}
