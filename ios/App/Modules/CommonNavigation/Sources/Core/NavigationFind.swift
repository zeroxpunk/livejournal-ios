//
//  NavigationFind.swift
//  Navigator
//
//  Created by Michael Long on 1/18/25.
//

import SwiftUI

extension Navigator {

    /// Returns first navigator found with given name
    @MainActor public func named(_ name: String) -> Navigator? {
        if let state = state.root.recursiveFindChild({ $0.name == name }) {
            return Navigator(state: state)
        }
        return nil
    }

    /// Returns child navigator found with given name
    @MainActor public func child(named name: String) -> Navigator? {
        if let state = state.recursiveFindChild({ $0.name == name }) {
            return Navigator(state: state)
        }
        return nil
    }

}

extension NavigationState {
    
    /// Find a parent state that matches the current condition
    internal func recursiveFindParent(_ condition: (NavigationState) -> Bool) -> NavigationState? {
        if let parent = parent {
            if condition(parent) {
                return parent
            } else {
                return parent.recursiveFindParent(condition)
            }
        }
        return nil
    }

    /// Finds a child state that matches the current condition starting from the current node
    internal func recursiveFindChild(_ condition: (NavigationState) -> Bool) -> NavigationState? {
        if condition(self) {
            return self
        }
        for child in children.values {
            if let state = child.object, let found = state.recursiveFindChild(condition) {
                return found
            }
        }
        return nil
    }

}
