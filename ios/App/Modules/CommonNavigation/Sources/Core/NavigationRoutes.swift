//
//  NavigationRoutes.swift
//  Navigator
//
//  Created by Michael Long on 2/3/25.
//

import SwiftUI

nonisolated public protocol NavigationRoutes: Hashable {}

extension Navigator {
    @MainActor
    public func perform<R: NavigationRoutes>(route: R) {
        send(route)
    }
}

public protocol NavigationRouteHandling {
    associatedtype Route: NavigationRoutes
    @MainActor
    func route(to route: Route, with navigator: Navigator)
}

extension View {
    public func onNavigationRoute<R: NavigationRouteHandling>(_ router: R) -> some View {
        self.onNavigationReceive { (route: R.Route, navigator) in
            router.route(to: route, with: navigator)
            return .auto
        }
    }
}
