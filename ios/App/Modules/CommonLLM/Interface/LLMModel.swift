import Foundation

public enum LLMModel: String, CaseIterable, Sendable {
    case gemma32B = "gemma-3n-E2B-it-int4"
    case gemma34B = "gemma-3n-E4B-it-int4"
    
    var fileName: String { "\(rawValue).task" }
}
