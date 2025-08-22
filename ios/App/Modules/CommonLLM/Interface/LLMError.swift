import Foundation

public enum LLMError: LocalizedError, Sendable {
    case modelNotFound(String)
    case initializationFailed(String)
    case sessionCreationFailed
    
    public var errorDescription: String? {
        switch self {
        case .modelNotFound(let model): 
            return "Model '\(model)' not found"
        case .initializationFailed(let reason): 
            return "Failed: \(reason)"
        case .sessionCreationFailed: 
            return "Failed to create session"
        }
    }
}
