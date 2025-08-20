//
//  NavigationViewProviding.swift
//  Navigator
//
//  Created by Michael Long on 1/14/25.
//

import SwiftUI

public protocol NavigationViews: Hashable {}

public protocol NavigationViewProviding<D> {
    associatedtype D: NavigationViews
    func view(for destination: D) -> AnyView
}

public struct NavigationViewProvider<V: View, D: NavigationViews>: NavigationViewProviding {
    private let builder: (D) -> V
    public init(@ViewBuilder builder: @escaping (D) -> V) {
        self.builder = builder
    }
    public func view(for destination: D) -> AnyView {
        AnyView(builder(destination))
    }
}

public struct MockNavigationViewProvider<D: NavigationViews>: NavigationViewProviding {
    public init() {}
    public func view(for destination: D) -> AnyView {
        AnyView(EmptyView())
    }
}
