//
//  Callback.swift
//  Navigator
//
//  Created by Michael Long on 2/12/25.
//

import SwiftUI

// Allows callback handlers to be passed in NavigationDestination types as a Hashable type based on its name.
//
// Note, however, that Callback handlers are NOT Codable and as such will disable state restoration in any ManagedNavigationStack that uses them.
//
// Using callback handlers between views will also interfere with deep linking, since URL handlers and other deep linking mechanisms will probably
// be unable to synthesize the correct callback closures externally.
//
// Consider navigation Send or Checkpoints with values instead.
public struct Callback<Value>: Hashable, Equatable {

    public let identifier: String
    public let handler: (Value) -> Void

    public init(_ identifier: String = UUID().uuidString, handler: @escaping (Value) -> Void) {
        self.identifier = identifier
        self.handler = handler
    }

    public func callAsFunction(_ value: Value) {
        handler(value)
    }

    public func hash(into hasher: inout Hasher) {
       hasher.combine(identifier)
    }

    public static func == (lhs: Callback<Value>, rhs: Callback<Value>) -> Bool {
        lhs.identifier == rhs.identifier
    }

}
