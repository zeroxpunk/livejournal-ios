//
//  NavigationPage.swift
//  Navigator
//
//  Created by Michael Long on 11/10/24.
//

import SwiftUI

/// Provides enumerated navigation types than can be translated into Views.
///
/// NavigationDestination types can be used in order to push and present views as needed.
///
/// This can happen using...
///
/// * Standard SwiftUI modifiers like `NavigationLink(value:label:)`.
/// * Imperatively by asking a ``Navigator`` to perform the desired action.
/// * Or via a deep link action enabled by a ``NavigationURLHandler``.
///
/// They're one of the core elements that make Navigator possible.
///
/// ### Defining Navigation Destinations
/// Destinations are typically just a simple list of enumerated values.
/// ```swift
/// public enum HomeDestinations {
///     case page2
///     case page3
///     case pageN(Int)
/// }
/// ```
/// Along with an extension that provides the correct view for a specific case.
/// ```swift
/// extension HomeDestinations: NavigationDestination {
///     public var body: some View {
///         switch self {
///         case .page2:
///             HomePage2View()
///         case .page3:
///             HomePage3View()
///         case .pageN(let value):
///             HomePageNView(number: value)
///         }
///     }
/// }
/// ```
/// Yes, NavigationDestination's are Views!
///
/// Note how associated values can be used to pass parameters to views as needed.
///
/// > Important: As of 6.2 it looks like `NavigationDestination` conformance **must** be done as an extension and **not** on the original
/// enumeration. This aligns with Swift 6.2’s requirement that protocol isolation must be explicit at the conformance site.
///
/// ### Using Navigation Destinations
/// This can be done via using a standard SwiftUI `NavigationLink(value:label:)` view.
/// ```swift
/// NavigationLink(value: HomeDestinations.page3) {
///     Text("Link to Home Page 3!")
/// }
/// ```
/// Or imperatively by asking a Navigator to perform the desired action.
/// ```swift
/// Button("Button Navigate to Home Page 55") {
///     navigator.navigate(to: HomeDestinations.pageN(55))
/// }
/// ```
///
/// ### Registering Navigation Destinations
/// Like traditional `NavigationStack` destination types, `NavigationDestination` types need to be registered with the enclosing
/// navigation stack in order for standard `NavigationLink(value:label:)` transitions to work correctly.
///
/// But since each `NavigationDestination` already defines the view to be provided, registering destination types can be done
/// using a simple one-line view modifier.
/// ```swift
/// ManagedNavigationStack {
///     HomeView()
///         .navigationDestination(HomeDestinations.self)
/// }
/// ```
/// This also makes using the same destination type with more than one navigation stack a lot easier.
///
/// ### Navigation Methods
/// `NavigationDestination` can also be extended to provide a distinct ``NavigationMethod`` for each enumerated type.
/// ```swift
/// extension HomeDestinations: NavigationDestination {
///     public var method: NavigationMethod {
///         switch self {
///         case .page3:
///             .sheet
///         default:
///             .push
///         }
///     }
/// }
/// ```
/// In this case, should `navigator.navigate(to: HomeDestinations.page3)` be called, Navigator will automatically present that view in a
/// sheet. All other views will be pushed onto the navigation stack.
///
/// > Important: When using `NavigationLink(value:label:)` the method will be ignored and SwiftUI will push
/// the value onto the navigation stack as it would normally.
@MainActor public protocol NavigationDestination: Hashable, Equatable, Identifiable, View {

    /// Can be overridden to define a specific presentation type for each destination.
    var method: NavigationMethod { get }

    /// Can be overridden to define a specific send resume type for each destination.
    var receiveResumeType: NavigationReceiveResumeType { get }

}

extension NavigationDestination {

    /// Default method for `.navigate(to:)`.
    public var method: NavigationMethod {
        .push
    }

    /// Default resume behavior.
    public var receiveResumeType: NavigationReceiveResumeType {
        .auto
    }

    /// Convenience function returns AnyView.
    @MainActor public func asAnyView() -> AnyView {
        AnyView(body)
    }

}

extension NavigationDestination {

    /// Default implementation of Identifiable id.
    public nonisolated var id: Int {
        self.hashValue
    }

    /// Equatable conformance.
    public nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

}

extension NavigationDestination {

    /// Convenience functions return view.
    @available(*, deprecated, message: "Use plain value instead e.g. 'MyDestination.page2' and not 'MyDestination.page2.view'.")
    @MainActor @ViewBuilder var view: some View {
        body
    }

    @available(*, deprecated, message: "Use plain value instead e.g. 'MyDestination.page2' and not 'MyDestination.page2()'.")
    @MainActor public func callAsFunction() -> some View {
        body
    }

}

extension View {
    /// Registers ``NavigationDestination`` types in order to enable `navigate(to:)` and `NavigationLink(value:label)` behaviors.
    /// ```swift
    /// ManagedNavigationStack {
    ///     HomeView()
    ///         .navigationDestination(HomeDestinations.self)
    /// }
    /// ```
    /// This also makes using the same destination type with more than one navigation stack a lot easier.
    ///
    /// Important: NavigationDestination must be registered using this function!
    public func navigationDestination<D: NavigationDestination>(_ destination: D.Type) -> some View {
        self.modifier(NavigationDestinationModifier(destination: destination))
    }

    public func navigationDestinationAutoReceive<D: NavigationDestination>(_ destination: D.Type) -> some View {
        self
            .modifier(NavigationDestinationModifier(destination: destination))
            .navigationAutoReceive(D.self)
    }

}

private struct NavigationDestinationModifier<D: NavigationDestination>: ViewModifier {
    let destination: D.Type
    @Environment(\.navigator) var navigator
    func body(content: Content) -> some View {
        let _ = navigator.register(D.self)
        content
            .navigationDestination(for: D.self) { destination in
                destination
                    // propagates environment so destination continues to use the same navigator
                    // this is primarily needed when using NavigationSplitView
                    .environment(\.navigator, navigator)
            }
    }
}

extension Navigator {

    public func register<D: NavigationDestination>(_ destination: D.Type) -> Void {
        #if DEBUG
        state.register(destination)
        #endif
    }
    
}

extension NavigationState {

    /// Checks for known navigation destination
    internal func known<D: NavigationDestination>(destination: D) -> Bool {
        navigationDestinations.contains(ObjectIdentifier(D.self))
    }

    /// Register the specified navigation destination type with the current navigation state.
    internal func register<D: NavigationDestination>(_ type: D.Type) -> Void {
        if owner != .stack {
            log(.warning("\(D.self) registration not within a ManagedNavigationStack"))
        }
        navigationDestinations.insert(ObjectIdentifier(D.self))
    }

}
