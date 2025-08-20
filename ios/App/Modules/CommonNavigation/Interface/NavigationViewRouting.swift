//
//  NavigationViewRouting.swift
//  Navigator
//
//  Created by Michael Long on 1/14/25.
//

import SwiftUI

public protocol NavigationRouting<R> {
    associatedtype R: NavigationRoutes
    @MainActor func route(to destination: R) throws
}

public struct NavigationRouter<R: NavigationRoutes>: NavigationRouting {
    private let navigator: Navigator
    private let router: (R) throws -> Void
    public init(_ navigator: Navigator, router: @escaping (R) -> Void) {
        self.navigator = navigator
        self.router = router
    }
    @MainActor public func route(to destination: R) throws {
        try router(destination)
    }
}

public struct MockNavigationRouter<R: NavigationRoutes>: NavigationRouting {
    public init() {}
    @MainActor public func route(to destination: R) throws {}
}
