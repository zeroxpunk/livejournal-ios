//
//  NavigationAction.swift
//  Navigator
//
//  Created by Michael Long on 1/10/25.
//

import SwiftUI

extension Navigator {

    @MainActor
    public func perform(_ actions: NavigationAction...) {
        send(values: actions)
    }

    @MainActor
    public func perform(actions: [NavigationAction]) {
        send(values: actions)
    }

}

nonisolated public struct NavigationAction: Hashable {

    public let name: String

    private let action: (Navigator) -> NavigationReceiveResumeType

    public init(_ name: String = #function, action: @escaping (Navigator) -> NavigationReceiveResumeType) {
        self.name = name
        self.action = action
    }

    public func callAsFunction(_ navigator: Navigator) -> NavigationReceiveResumeType {
        action(navigator)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    public static func == (lhs: NavigationAction, rhs: NavigationAction) -> Bool {
        lhs.name == rhs.name
    }

}

extension NavigationAction {

    /// Action allows user to construct actions on the fly
    @MainActor public static func action(handler: @escaping (Navigator) -> NavigationReceiveResumeType) -> NavigationAction {
        .init(action: handler)
    }

    /// Dismisses all presented views.
    ///
    /// If navigation dismissal is locked, this action will cancel and no further actions in this sequence will be executed.
    @MainActor public static var dismissAny: NavigationAction {
        .init {
            do {
                return try $0.dismissAny() ? .auto : .immediately
            } catch {
                return .cancel
            }
        }
    }

    /// Empty action, usually used as a placeholder for a definition to be provided later.
    @MainActor public static var empty: NavigationAction {
        .init { _ in .immediately }
    }

    /// Cancels if navigation is locked.
    @MainActor public static var locked: NavigationAction {
        .init { navigator in
            navigator.state.isNavigationLocked ? .cancel : .immediately
        }
    }

    /// Empty action, usually used as a placeholder for a definition to be provided later.
    @MainActor public static var pause: NavigationAction {
        .init { _ in .pause }
    }

    /// Finds named navigator and pops it back to the root.
    @MainActor public static func popAll(in name: String) -> NavigationAction {
        .init { navigator in
            if let found = navigator.named(name) {
                return found.popAll() ? .auto : .immediately
            }
            return .cancel
        }
    }

    /// Dismisses any presented views and resets all paths back to zero.
    ///
    ///  Inserts value into the queue for next send in order to correctly handle that values resume type.
    @MainActor public static var popAny: NavigationAction {
        .init {
            do {
                return try $0.popAny() ? .auto : .immediately
            } catch {
                return .cancel
            }
        }
    }

    /// Dismisses any presented views and resets all paths back to zero.
    ///
    ///  Inserts value into the queue for next send in order to correctly handle that values resume type.
    @MainActor public static var reset: NavigationAction {
        .init { _ in .inserting([NavigationAction.dismissAny, NavigationAction.popAny]) }
    }

    /// Sends value via navigation send.
    ///
    ///  Inserts value into the queue for next send in order to correctly handle that values resume type.
    @MainActor public static func send(_ value: any Hashable) -> NavigationAction {
        .init { _ in .inserting([value]) }
    }

    /// Finds named navigator and passes it to closure for imperative action.
    ///
    /// If not found the closure will not be called and this action will cancel.
    @MainActor public static func with(navigator name: String, perform: @escaping (Navigator) -> Void) -> NavigationAction {
        .init { navigator in
            if let found = navigator.named(name) {
                perform(found)
                return .auto
            }
            return .cancel
        }
    }

}
