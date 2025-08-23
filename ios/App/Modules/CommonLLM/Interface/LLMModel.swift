import Foundation

public enum LLMModel: String, CaseIterable, Sendable {
    case gemma1B = "gemma3-1b-it-int4"
    case gemma2B = "gemma-3n-E2B-it-int4"
    case gemma4B = "gemma-3n-E4B-it-int4"
    
    var fileName: String { "\(rawValue).task" }
}

