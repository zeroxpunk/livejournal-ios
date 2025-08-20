//
//  ManagedNavigationStack.swift
//  Navigator
//
//  Created by Michael Long on 11/10/24.
//

import SwiftUI

/// Creates a NavigationStack and its associated Navigator that "manages" the stack.
///
/// Using ManagedNavigationStack is easy. Just use it where you'd normally used a `NavigationStack`.
/// ```swift
/// struct RootView: View {
///     var body: some View {
///         ManagedNavigationStack {
///             HomeView()
///                 .navigationDestination(HomeDestinations.self)
///         }
///     }
/// }
/// ```
/// ### Dismissible
/// Presented ManagedNavigationStacks are automatically dismissible.
/// ### State Restoration
/// ManagedNavigationStack supports state restoration out of the box. For state restoration to work, however, a
/// few conditions apply.
///
/// 1.  The ManagedNavigationStack must have a unique scene name.
/// 2.  All ``NavigationDestination`` types pushed onto the stack must be Codable.
/// 3.  A state restoration key was provided in ``NavigationConfiguration``.
///
/// See the State Restoration documentation for more.
@MainActor
public struct ManagedNavigationStack<Content: View>: View {

    @Environment(\.navigator) private var navigator: Navigator
    @Environment(\.isPresented) private var isPresented

    private let name: String?
    private let content: (Navigator) -> Content
    private let isScene: Bool

    /// Initializes NavigationStack.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.name = nil
        self.content = { _ in content() }
        self.isScene = false
    }

    /// Initializes NavigationStack passing Navigator into closure.
    public init(@ViewBuilder content: @escaping (Navigator) -> Content) {
        self.name = nil
        self.content = { navigator in content(navigator) }
        self.isScene = false
    }

    /// Initializes named NavigationStack.
    public init(name: String, @ViewBuilder content: @escaping () -> Content) {
        self.name = name
        self.content = { _ in content() }
        self.isScene = false
    }

    /// Initializes named NavigationStack passing Navigator into closure.
    public init(name: String, @ViewBuilder content: @escaping (Navigator) -> Content) {
        self.name = name
        self.content = { navigator in content(navigator) }
        self.isScene = false
    }

    /// Initializes NavigationStack with name needed to enable scene storage.
    public init(scene name: String, @ViewBuilder content: @escaping () -> Content) {
        self.name = name
        self.content = { _ in content() }
        self.isScene = true
    }

    /// Initializes NavigationStack with name needed to enable scene storage passing Navigator into closure.
    public init(scene name: String, @ViewBuilder content: @escaping (Navigator) -> Content) {
        self.name = name
        self.content = { navigator in content(navigator) }
        self.isScene = true
    }

    public var body: some View {
        if isWrappedInPresentationView {
            WrappedNavigationStack(state: navigator.state.setting(name), name: sceneName, content: content(navigator))
        } else {
            CreateNavigationStack(state: .init(owner: .stack, name: name), name: sceneName, content: content)
        }
    }

    internal var isWrappedInPresentationView: Bool {
        isPresented && navigator.state.owner == .presenter
    }

    internal var sceneName: String? {
        isScene ? name : nil
    }

    // Allows NavigationStack to use Navigator and NavigationState provided by ManagedPresentationView
    internal struct WrappedNavigationStack: View {

        @ObservedObject internal var state: NavigationState
        internal let name: String?
        internal let content: Content

        init(state: NavigationState, name: String?, content: Content) {
            self.state = state
            self.name = name
            self.content = content
        }
        var body: some View {
            NavigationStack(path: $state.path) {
                content
            }
            .modifier(NavigationSceneStorageModifier(state: state, name: name))
        }

    }

    // Allow NavigationStack to create and manage its own Navigator and NavigationState
    internal struct CreateNavigationStack: View {

        @State internal var state: NavigationState
        internal let name: String?
        internal let content: (Navigator) -> Content
    
        @Environment(\.navigator) private var parent
        @Environment(\.isPresented) private var isPresented
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            let navigator = Navigator(state: state, parent: parent, dismissible: isPresented ? dismiss : nil)
            NavigationStackContentView(state: state, content: content(navigator))
                .modifier(NavigationPresentationModifiers(state: state))
                .modifier(NavigationSceneStorageModifier(state: state, name: name))
                .environment(\.navigator, navigator)
        }

        struct NavigationStackContentView: View {
            @StateObject internal var state: NavigationState
            internal let content: Content
            var body: some View {
                NavigationStack(path: $state.path) {
                    content
                }
            }
        }
    }

}

// Navigator (Root)
// --Tab 1 - ManagedNavigationStack (Navigator)
// --Tab 2 - ManagedNavigationStack (Navigator)
// --Tab 3 - ManagedNavigationStack (Navigator)
// ----ManagedPresentationView (Navigator)
// ------ManagedNavigationStack (w/ManagedPresentationView's Navigator)
// --------ManagedPresentationView (Navigator)
// ----------ManagedNavigationStack (w/ManagedPresentationView's Navigator)

// RootNavigator
// - isPresented == false
//
// ManagedNavigationStack
// - isPresented == false
// - Needs New Navigator
// - Provides sheets
//
// -----------------------------
//
// PresentedView
// - isPresented == true
// - Provides New Navigator
// - Provides sheets
//
//   ManagedNavigationStack
//   - Uses Existing Navigator if PresentedView
//   - Uses Existing Sheets
//
// -----------------------------
//
// PresentedView
// - isPresented == true
// - Provides New Navigator
// - Provides sheets
//
//   ManagedNavigationStack
//   - Uses Existing Navigator
//   - Uses Existing Sheets
//
// -----------------------------
//
// PresentedView
// - isPresented == true
// - Provides New Navigator
// - Provides sheets
//
//   SomeView
//   - Uses Existing Navigator
//   - Uses Existing Sheets
//
