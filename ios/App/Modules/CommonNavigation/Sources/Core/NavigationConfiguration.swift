//
//  NavigationConfiguration.swift
//  Navigator
//
//  Created by Michael Long on 12/1/24.
//

import SwiftUI

/// Configuration options for Navigator.
///
/// Allows the developer to modify some of Navigator's basic behavior by configuring and installing a
/// root Navigator in the application's navigation tree.
/// ```swift
/// @main
/// struct NavigatorDemoApp: App {
///     var body: some Scene {
///         WindowGroup {
///             RootTabView()
///                 .environment(\.navigator, Navigator(configuration: configuration))
///         }
///     }
///     var configuration: NavigationConfiguration {
///         .init(restorationKey: "1.0.0", verbosity: .info)
///     }
/// }
/// ```
nonisolated public struct NavigationConfiguration {

    /// Determines whether or not users should see animation steps when deep linking.
    ///
    /// Set value to 0.0 for maximum animation speed. Longer (0.5) to let the user see the distinct "steps" involved in navigating
    /// to a new destination. Default is 0.1.
    public let executionDelay: TimeInterval

    /// Provide a restorationKey to enable state restoration in named ManagedNavigationControllers.
    ///
    /// Increment or change the key when adding/removing checkpoints or changing destination types.
    ///
    /// If no restorationKey is provided then navigation state restoration is disabled.
    public let restorationKey: String?

    /// Allows the developer to log navigation messages to the console or to their own logging system.
    ///
    /// If logger is nil then nothing is logged.
    public let logger: ((_ event: NavigationEvent) -> Void)?

    /// Logging verbosity
    public let verbosity: NavigationEvent.Verbosity

    public init(
        restorationKey: String? = nil,
        logger: ((NavigationEvent) -> Void)? = {
            #if DEBUG
            print($0)
            #endif
        },
        executionDelay: TimeInterval = 0.3,
        verbosity: NavigationEvent.Verbosity = .warning
    ) {
        if #available(iOS 18, *) {
            self.executionDelay = min(max(0.3, executionDelay), 5.0)
        } else {
            self.executionDelay = min(max(0.7, executionDelay), 5.0)
        }
        self.restorationKey = restorationKey
        self.logger = logger
        self.verbosity = verbosity
    }

}
