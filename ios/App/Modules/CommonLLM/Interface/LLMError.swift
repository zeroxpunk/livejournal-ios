import Foundation

public enum LLMError: LocalizedError, Sendable {
    case modelNotFound(String)
    case initializationFailed(String)
    case sessionCreationFailed
    case contextWindowExceeded(current: Int, max: Int)
    
    public var errorDescription: String? {
        switch self {
        case .modelNotFound(let model): 
            return "Model '\(model)' not found"
        case .initializationFailed(let reason): 
            return "Failed: \(reason)"
        case .sessionCreationFailed: 
            return "Failed to create session"
        case .contextWindowExceeded(let current, let max):
            return "Context window exceeded: \(current) tokens exceeds maximum of \(max)"
        }
    }
}
