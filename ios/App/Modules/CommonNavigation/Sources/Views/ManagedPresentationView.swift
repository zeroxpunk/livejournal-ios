//
//  ManagedPresentationView.swift
//  Navigator
//
//  Created by Michael Long on 1/22/25.
//

import SwiftUI

/// Allows presented views not in a navigation stack to be dismissed using a Navigator.
///
/// Also supports nested sheets and covers.
///
/// If you present sheets or covers in your own code, outside of `navigate(to:)`, and if those presented
/// views don't use ``ManagedNavigationStack``, then `ManagedPresentationView`  tells Navigator about them.
/// ```swift
/// Button("Present Page 3 via Sheet") {
///     showSettings = .page3
/// }
/// .sheet(item: $showSettings) { destination in
///     ManagedPresentationView {
///         destination()
///     }
/// }
/// ```
/// That in turn allows them to be manipulated or closed when performing deep linking actions like dismissAny().
///
/// One can also use the ``managedPresentationView()`` modifier which does the same thing.
/// ```swift
/// .sheet(item: $showSettings) { destination in
///     destination()
///         .managedPresentationView()
/// }
/// ```
/// > Warning: Failure to tag presented views as such can lead to inconsistent deep linking and navigation behavior.
@MainActor
public struct ManagedPresentationView<Content: View>: View {

    @Environment(\.navigator) private var parent: Navigator
    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) private var dismiss

    @StateObject private var state: NavigationState

    private let content: Content

    /// Initializes NavigationStack
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self._state = .init(wrappedValue: .init(owner: .presenter, name: nil))
    }

    public var body: some View {
        content
            .modifier(NavigationPresentationModifiers(state: state))
            .environment(\.navigator, Navigator(state: state, parent: parent, dismissible: isPresented ? dismiss : nil))
    }

}
