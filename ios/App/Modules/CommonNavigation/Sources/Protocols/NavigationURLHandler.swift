//
//  NavigationURLHander.swift
//  Navigator
//
//  Created by Michael Long on 11/21/24.
//

import SwiftUI

/// Provides Deep Linking support.
///
/// A NavigationURLHander examines the passed URL and converts it into a set of NavigationDestination or Hashable values
/// that can be broadcast throughout the application using `navigator.send()`.
/// ```swift
/// .onNavigationOpenURL(
///     HomeURLHander(),
///     SettingsURLHander()
/// )
///```
/// Developers can add `.onNavigationReceive` modifiers to their code to listen for specific types and perform specific actions when they're
/// received.
///
/// For example, a URL like "navigator://app/settings" can be translated by the SettingsURLHander into `send(RootTabs.settings)`, which is
/// then received to set the selected tab in a given view.
/// ```swift
/// // typical receive handler
/// .onNavigationReceive { (tab: RootTabs) in
///     selectedTab = tab
///     return .auto
/// }
///
/// // alternative assignment shortcut
/// .onNavigationReceive(assign: $tab)
///```
public protocol NavigationURLHandler {
    /// Method examines the passed URL, parses the values, and routes it as needed.
    ///
    /// If a given handler doesn't recognize the URL in question, it returns false. Handlers are processed in order until the URL is recognized
    /// or until recognition fails.
    @MainActor func handles(_ url: URL, with navigator: Navigator) -> Bool
}

extension View {
    /// Adds Deep Linking support to an application.
    ///
    /// The `onNavigationOpenURL` modifier adds an `onOpenURL` modifier to a view and translates the incoming URL to a set of destinations
    /// using the provided set of NavigationURLHanders.
    /// ```swift
    /// .onNavigationOpenURL(
    ///     HomeURLHandler(),
    ///     SettingsURLHandler()
    /// )
    ///```
    ///The parameters passed to this function are variadic, one or more.
    public func onNavigationOpenURL(_ handlers: (any NavigationURLHandler)...) -> some View {
        self.modifier(OnNavigationOpenURLModifier(handlers: handlers))
    }
    /// Additional interface that takes an array of handlers
    public func onNavigationOpenURL(_ handlers: [any NavigationURLHandler]) -> some View {
        self.modifier(OnNavigationOpenURLModifier(handlers: handlers))
    }
}

private struct OnNavigationOpenURLModifier: ViewModifier {
    internal let handlers: [any NavigationURLHandler]
    @Environment(\.navigator) var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) {
                handleOpenURL($0.webpageURL)
            }
            .onOpenURL {
                handleOpenURL($0)
            }
    }
    func handleOpenURL(_ url: URL?) {
        guard let url else { return }
        _ = handlers.first {
            $0.handles(url, with: navigator)
        }
    }
}
