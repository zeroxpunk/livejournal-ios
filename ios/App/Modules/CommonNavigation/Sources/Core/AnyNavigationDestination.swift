//
//  AnyNavigationDestination.swift
//  Navigator
//
//  Created by Michael Long on 11/10/24.
//

import SwiftUI

/// Wrapper boxes a specific NavigationDestination.
public struct AnyNavigationDestination {
    public var wrapped: any NavigationDestination
    public var method: NavigationMethod
}

extension AnyNavigationDestination: Identifiable {

    public nonisolated var id: Int { wrapped.id }

    @MainActor public func callAsFunction() -> AnyView {
        wrapped.asAnyView()
    }

}

extension AnyNavigationDestination: Hashable, Equatable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public static func == (lhs: AnyNavigationDestination, rhs: AnyNavigationDestination) -> Bool {
        lhs.id == rhs.id
    }

}

extension AnyNavigationDestination: Codable {

    // Adapted from https://www.pointfree.co/blog/posts/78-reverse-engineering-swiftui-s-navigationpath-codability

    // convert data to NavigationDestination
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let typeName = try container.decode(String.self)
        let type = _typeByName(typeName)
        guard let type = type as? any Decodable.Type else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "\(typeName) is not decodable.")
        }
        guard let destination = (try container.decode(type)) as? any NavigationDestination else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "\(typeName) is not decodable.")
        }
        wrapped = destination
        method = try container.decode(NavigationMethod.self)
    }

    // convert NavigationDestination to storable data
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(_mangledTypeName(type(of: wrapped)))
        guard let element = wrapped as? any Encodable else {
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "\(type(of: wrapped)) is not encodable.")
            throw EncodingError.invalidValue(wrapped, context)
        }
        try container.encode(element)
    }

}
