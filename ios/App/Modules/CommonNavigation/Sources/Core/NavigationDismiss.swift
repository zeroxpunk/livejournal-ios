//
//  NavigationDismiss.swift
//  Navigator
//
//  Created by Michael Long on 11/27/24.
//

import SwiftUI

extension Navigator {

    /// Dismisses the currently presented ManagedNavigationStack.
    /// ```swift
    /// Button("Dismiss") {
    ///     navigator.dismiss()
    /// }
    /// ```
    /// Note that unlike Apple's dismiss environment variable, Navigator's dismiss function doesn't "pop" the current view on the navigation path.
    ///
    /// It exists solely to dismiss the currently presented view from within the
    /// currently presented view.
    @MainActor
    @discardableResult
    public func dismiss() -> Bool {
        state.dismiss()
    }

    /// Dismisses presented sheet or fullScreenCover views presented by this Navigator.
    /// ```swift
    /// Button("Dismiss") {
    ///     navigator.dismissPresentedViews()
    /// }
    /// ```
    /// This is used in the parent view to dismiss its children, effectively the opposite of `dismiss()`.
    @MainActor
    public func dismissPresentedViews() {
        state.sheet = nil
        state.cover = nil
    }

    /// Dismisses *any* `ManagedNavigationStack` or `ManagedPresentationView` presented by this Navigator
    /// or by any child of this Navigator in the current navigation tree.
    /// ```swift
    /// Button("Dismiss") {
    ///     navigator.dismissAny()
    /// }
    /// ```
    /// This is used in the parent view to dismiss its children, effectively the opposite of `dismiss()`.
    @MainActor
    @discardableResult
    public func dismissAnyChildren() -> Bool {
        state.dismissAnyChildren()
    }

    /// Returns to the root Navigator and dismisses *any* presented `ManagedNavigationStack` or `ManagedPresentationView`.
    /// ```swift
    /// Button("Dismiss") {
    ///     navigator.dismissAny()
    /// }
    /// ```
    /// This functionality is used extensively in deep linking and cross-module linking in
    /// order to clear any presented views prior to taking the user elsewhere in the application.
    @MainActor
    @discardableResult
    public func dismissAny() throws -> Bool {
        try state.dismissAny()
    }

}

extension View {

    /// Dismisses the current `ManagedNavigationStack` or `ManagedPresentationView` if presented.
    ///
    /// Trigger value will be reset to false on dismissal.
    public func navigationDismiss(trigger: Binding<Bool>) -> some View {
        self.modifier(NavigationDismissModifier(trigger: trigger, action: .dismiss))
    }

    /// Dismisses any sheets or covers presented by this navigator.
    ///
    /// Trigger value will be reset to false on dismissal.
    public func navigationDismissPresented(trigger: Binding<Bool>) -> some View {
        self.modifier(NavigationDismissModifier(trigger: trigger, action: .dismissPresentedViews))
    }

    /// Dismisses *any* `ManagedNavigationStack` or `ManagedPresentationView` presented by this Navigator or by any child of this Navigator in the current
    ///  navigation tree.
    ///
    /// Trigger value will be reset to false on dismissal.
    public func navigationDismissAnyChildren(trigger: Binding<Bool>) -> some View {
        self.modifier(NavigationDismissModifier(trigger: trigger, action: .dismissAnyChildren))
    }

    /// Returns to the root Navigator and dismisses *any* presented `ManagedNavigationStack` or `ManagedPresentationView`.
    ///
    /// Trigger value will be reset to false on dismissal.
    public func navigationDismissAny(trigger: Binding<Bool>) -> some View {
        self.modifier(NavigationDismissModifier(trigger: trigger, action: .dismissAny))
    }

    /// Allows presented views not in a navigation stack to be dismissed using a Navigator.
    @available(*, deprecated, renamed: "managedPresentationView", message: "Use `managedPresentationView()` instead.")
    public func navigationDismissible() -> some View {
        ManagedPresentationView {
            self
        }
    }

}

extension NavigationState {

    @MainActor internal func dismiss() -> Bool {
        if isPresented {
            dismissAction?()
            dismissAction = nil
            log(.navigation(.dismissed))
            return true
        }
        return false
    }

    /// Returns to the root Navigator and dismisses *any* presented ManagedNavigationStack.
    @MainActor internal func dismissAny() throws -> Bool {
        guard !isNavigationLocked else {
            log(.warning("Navigator \(id) error navigation locked"))
            throw NavigationError.navigationLocked
        }
        return root.dismissAnyChildren()
    }

    /// Dismisses *any* ManagedNavigationStack presented by this Navigator.
    @MainActor internal func dismissAnyChildren() -> Bool {
        for child in children.values {
            if let childNavigator = child.object {
                if #available (iOS 18.0, *) {
                    if childNavigator.dismiss() || childNavigator.dismissAnyChildren() {
                        return true
                    }
                } else {
                    var dismissed: Bool
                    // both functions need to execute, || would short-circuit
                    dismissed = childNavigator.dismissAnyChildren()
                    dismissed = childNavigator.dismiss() || dismissed
                    if dismissed {
                        return true
                    }
                }
            }
        }
        return false
    }

}

private struct NavigationDismissModifier: ViewModifier {

    enum Action {
        case dismiss
        case dismissPresentedViews
        case dismissAnyChildren
        case dismissAny
    }

    @Binding internal var trigger: Bool
    var action: Action

    @Environment(\.navigator) internal var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { trigger in
                if trigger {
                    self.trigger = false
                    switch action {
                    case .dismiss:
                        navigator.dismiss()
                    case .dismissPresentedViews:
                        navigator.dismissPresentedViews()
                    case .dismissAnyChildren:
                        navigator.dismissAnyChildren()
                    case .dismissAny:
                        _ = try? navigator.dismissAny()
                    }
                }
            }
    }

}
