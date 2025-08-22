import Foundation

public struct Message: Sendable {
    public enum Role: String, Sendable {
        case system
        case user
        case assistant
    }
    
    public let role: Role
    public let text: String
    
    public init(role: Role, text: String) {
        self.role = role
        self.text = text
    }
}
