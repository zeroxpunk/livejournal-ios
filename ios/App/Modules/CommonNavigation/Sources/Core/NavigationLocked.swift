//
//  NavigationLocked.swift
//  Navigator
//
//  Created by Michael Long on 11/30/24.
//

import SwiftUI

extension Navigator {

    /// Returns true if navigation is locked.
    public nonisolated var isNavigationLocked: Bool {
        state.isNavigationLocked
    }

}

extension View {

    /// Apply to a presented view on which you want to prevent global dismissal.
    @MainActor public func navigationLocked() -> some View {
        self.modifier(NavigationLockedModifier())
    }

}

extension NavigationState {

    internal var isNavigationLocked: Bool {
        !root.navigationLocks.isEmpty
    }

    internal func addNavigationLock(id: UUID) {
        root.navigationLocks.insert(id)
    }

    internal func removeNavigationLock(id: UUID) {
        root.navigationLocks.remove(id)
    }

}

private struct NavigationLockedModifier: ViewModifier {

    @StateObject private var sentinel: NavigationLockedSentinel = .init()
    @Environment(\.navigator) private var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .task {
                sentinel.lock(navigator)
            }
    }

}

private class NavigationLockedSentinel: ObservableObject {

    private let id: UUID = UUID()
    private var state: NavigationState?

    deinit {
        state?.removeNavigationLock(id: id)
    }

    func lock(_ navigator: Navigator) {
        self.state = navigator.root.state
        self.state?.addNavigationLock(id: id)
    }
    
}

