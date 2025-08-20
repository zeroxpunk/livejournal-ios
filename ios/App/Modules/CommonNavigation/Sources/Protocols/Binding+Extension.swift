//
//  Binding+Extension.swift
//  Navigator
//
//  Created by Michael Long on 2/12/25.
//

import SwiftUI

// Extension allows Bindings to be passed in NavigationDestination types as Hashable types if the bound type is also Hashable.
//
// Note, however, that Bindings are NOT Codable and as such will disable state restoration in any ManagedNavigationStack that uses them.
//
// Bindings between views will also interfere with deep linking, since URL handlers and other deep linking mechanisms will probably
// be unable to synthesize the correct binding.
//
// Consider navigation Send or Checkpoints with values instead.
extension Binding: @retroactive Hashable, @retroactive Equatable where Value: Hashable {

    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }

    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        lhs.wrappedValue.hashValue == rhs.wrappedValue.hashValue
    }

}
