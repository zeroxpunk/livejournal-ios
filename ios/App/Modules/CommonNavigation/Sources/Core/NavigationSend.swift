//
//  NavigationSend.swift
//  Navigator
//
//  Created by Michael Long on 11/14/24.
//

import Combine
import SwiftUI

extension Navigator {

    /// Sends a value or values to navigation receivers throughout the application.
    ///
    /// This is the core functionality behind deep linking support in Navigator.
    ///
    /// The primary difference between this and `navigate(to:)` is that you don't need to know what navigator is handling
    /// the request, nor does the value need to be of type ``NavigationDestination``.
    ///
    /// They just need to be `Hashable`.
    ///
    /// ### Sending Values
    /// The following code broadcasts a list of actions to be handled somewhere in the application. First it selects the Home tab,
    /// then navigates to Page 2.
    /// ```swift
    /// Button("Go To Tab Home, Page 2") {
    ///     navigator.send(
    ///         RootTabs.home,
    ///         HomeDestinations.page2
    ///     )
    /// }
    /// ```
    /// ### Receiving Values
    /// Receiving values is simple. Just register a receive handler for the desired type.
    /// ```swift
    /// .onNavigationReceive { (tab: RootTabs) in
    ///     if tab == selectedTab {
    ///         return .immediately
    ///     }
    ///     selectedTab = tab
    ///     return .auto
    /// }
    /// ```
    /// And then perform whatever action is needed on receipt.
    ///
    /// Here's the handler for `HomeDestinations`.`
    /// ```swift
    /// .onNavigationReceive { (destination: HomeDestinations, navigator) in
    ///     navigator.navigate(to: destination)
    ///     return .auto
    /// }
    /// ```
    ///
    /// Speaking of which, receive handlers return a value of type ``NavigationReceiveResumeType``, which tells Navigator how to
    /// process the remaining values in the queue. Additional values can be paused, cancelled, or simply processed normally.
    ///
    /// Note that there should be one and only one registered handler for a given type in the navigation tree. If more than
    /// one exists the first handler will consume the value and the remaining handlers should be ignored.
    @MainActor
    public func send(_ values: any Hashable...) {
        send(values: values)
    }

    @available(*, deprecated, renamed: "send", message: "Use send(...) instead.")
    @MainActor
    public func send(value: any Hashable) {
        send(values: [value])
    }

    @MainActor
    public func send(values: [any Hashable]) {
        guard let value: any Hashable = values.first else {
            return
        }
        let remainingValues = Array(values.dropFirst())
        if let action = value as? NavigationAction {
            log(.send(.performing(action)))
            resume(action(self), values: remainingValues)
        } else {
            log(.send(.sending(value)))
            state.publisher.send(NavigationSendValues(navigator: root, value: value, values: remainingValues))
        }
    }

    @MainActor
    internal func resume(_ action: NavigationReceiveResumeType, values: [any Hashable] = [], delay: TimeInterval? = nil) {
        switch action {
        case .auto:
            let delay: TimeInterval = delay ?? state.executionDelay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.send(values: values)
            }
        case .immediately:
            send(values: values)
        case .after(let interval):
            resume(.auto, values: values, delay: interval)
        case .inserting(let newValues):
            resume(.immediately, values: newValues + values)
        case .appending(let newValues):
            resume(.immediately, values: values + newValues)
        case .replacing(let newValues):
            resume(.immediately, values: newValues)
        case .pause:
            Navigator.resumableValues = values
        case .cancel:
            break
        }
    }

    /// Resumes sending any values paused by an onNavigationReceive handler.
    ///
    /// This allows for actions like authentication sequences to occur as part of a deep linking sequence. The onNavigationReceive
    /// handler pauses the sequence, and this function resumes them.
    @MainActor
    public func resume(condition: Bool = true) {
        guard condition, let values = Navigator.resumableValues else {
            return
        }
        Navigator.resumableValues = nil
        send(values: values)
    }

    /// Deletes any stored values that might have been paused by an onNavigationReceive handler.
    @MainActor
    public func cancelResume() {
        Navigator.resumableValues = nil
    }

    @MainActor internal static var resumableValues: [any Hashable]? = nil

}

extension View {

    /// Declarative access to `navigator.send(value:)`.
    ///
    /// Note that the bound optional value will be cleared immediately after it's sent.
    public func navigationSend<T: Hashable & Equatable>(_ item: Binding<T?>) -> some View {
        self.modifier(NavigationSendValueModifier<T>(item: item))
    }

    /// Declarative access to `navigator.send(values:)`.
    ///
    /// Note that the bound optional values will be cleared immediately after the first value is sent.
    public func navigationSend<T: Hashable & Equatable>(values: Binding<[T]?>) -> some View {
        self.modifier(NavigationSendValuesModifier<T>(values: values))
    }

    /// Handler receives values of a specific type broadcast via `navigator.send`.
    /// ```swift
    /// .onNavigationReceive { (tab: RootTabs) in
    ///     if tab == selectedTab {
    ///         return .immediately
    ///     }
    ///     selectedTab = tab
    ///     return .auto
    /// }
    /// ```
    /// Receive handlers return a value of type ``NavigationReceiveResumeType``. That tells Navigator how to process the remaining
    /// values in the queue.
    ///
    /// Note that there should be one and only one registered handler for a given type in the navigation tree. If more than
    /// one exists the first handler will consume the value and the remaining handlers should be ignored.
    public func onNavigationReceive<T: Hashable>(handler: @escaping NavigationReceiveResumeValueOnlyHandler<T>) -> some View {
        self.modifier(OnNavigationReceiveModifier(handler: { (value, _) in handler(value) }))
    }

    /// Handler receives values of a specific type broadcast via `navigator.send`.
    /// ```swift
    /// .onNavigationReceive { (destination: HomeDestinations, navigator) in
    ///     navigator.navigate(to: destination)
    ///     return .auto
    /// }
    /// ```
    /// This version passes in the current navigator in addition to the sent value.
    ///
    /// Receive handlers return a value of type ``NavigationReceiveResumeType``. That tells Navigator how to process the remaining
    /// values in the queue.
    ///
    /// Note that there should be one and only one registered handler for a given type in the navigation tree. If more than
    /// one exists the first handler will consume the value and the remaining handlers should be ignored.
    public func onNavigationReceive<T: Hashable>(handler: @escaping NavigationReceiveResumeHandler<T>) -> some View {
        self.modifier(OnNavigationReceiveModifier(handler: handler))
    }

    // Handler receives values of a specific type broadcast via `navigator.send` and assigns the result to bound value
    public func onNavigationReceive<T: Hashable & Equatable>(assign binding: Binding<T>, delay: TimeInterval? = nil) -> some View {
        self.modifier(OnNavigationReceiveModifier<T> { (value, _) in
            if binding.wrappedValue == value {
                return .immediately
            }
            binding.wrappedValue = value
            if let delay {
                return .after(delay)
            } else {
                return .auto
            }
        })
    }

    /// Convenience receiver for NavigationDestinations values broadcast via `navigator.send`.
    ///
    /// The following code navigates to a specific destination and returns normally.
    /// ```swift
    /// .onNavigationReceive { (destination: HomeDestinations, navigator) in
    ///     navigator.navigate(to: destination)
    ///     return .auto
    /// }
    /// ```
    /// That sequence occurs so often that there's a shortcut that does the same thing.
    /// ```swift
    /// .navigationAutoReceive(HomeDestinations.self)
    /// ```
    public func navigationAutoReceive<T: NavigationDestination>(_ type: T.Type) -> some View {
        self.modifier(OnNavigationReceiveModifier<T> { (value, navigator) in
            navigator.navigate(to: value)
            return .auto
        })
    }

    public func navigationResume() -> some View {
        self.modifier(NavigationResumeModifier())
    }

}

public typealias NavigationReceiveResumeHandler<T> = (_ value: T, _ navigator: Navigator) -> NavigationReceiveResumeType
public typealias NavigationReceiveResumeValueOnlyHandler<T> = (_ value: T) -> NavigationReceiveResumeType

public enum NavigationReceiveResumeType {
    /// Automatically resumes sending remaining values after a delay
    case auto

    /// Resumes sending remaining values immediately, without delay
    case immediately

    /// Automatically resumes sending remaining values after a specified delay
    case after(TimeInterval)

    ///  Replaces remaining values with new values after a brief delay
    case replacing([any Hashable])

    ///  Inserts new values into the queue
    case inserting([any Hashable])

    ///  Appends new values onto the queue
    case appending([any Hashable])

    /// Saves any remaining deep linking values for later resumption
    case pause

    /// Cancels any remaining values in the send queue
    case cancel
}

private struct NavigationSendValueModifier<T: Hashable & Equatable>: ViewModifier {
    @Binding internal var item: T?
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: item) { item in
                if let item {
                    navigator.send(item)
                    self.item = nil
                }
            }
    }
}

private struct NavigationSendValuesModifier<T: Hashable & Equatable>: ViewModifier {
    @Binding internal var values: [T]?
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: values) { values in
                if let values {
                    navigator.send(values: values)
                    self.values = nil
                }
            }
    }
}

private struct OnNavigationReceiveModifier<T: Hashable>: ViewModifier {
    internal let handler: NavigationReceiveResumeHandler<T>
    @Environment(\.navigator) var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onReceive(navigator.state.publisher) { values in
                if let value: T = values.consume() {
                    navigator.log(.send(.receiving(value)))
                    let type = handler(value, navigator)
                    if case .auto = type, let destination = value as? any NavigationDestination {
                        values.resume(destination.receiveResumeType)
                    } else {
                        values.resume(type)
                    }
                }
            }
    }
}

private struct NavigationResumeModifier: ViewModifier {
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .task {
                navigator.resume()
            }
    }
}

internal final class NavigationSendValues {

    internal let navigator: Navigator
    internal let value: any Hashable
    internal let values: [any Hashable]
    internal let identifier: String?

    internal var consumed: Bool = false

    internal init(navigator: Navigator, value: any Hashable, values: [any Hashable], identifier: String? = nil) {
        self.navigator = navigator
        self.value = value
        self.values = values
        self.identifier = identifier
    }

    deinit {
        if consumed == false {
            navigator.log(.error("missing receive handler for type: \(type(of: value))!!!"))
        }
    }

    @MainActor
    internal func consume<T>(_ identifier: String? = nil) -> T? {
        if let value = value as? T, self.identifier == identifier {
            if consumed {
                navigator.log(.error("additional receive handlers ignored for type: \(type(of: value))!!!"))
                return nil
            }
            consumed.toggle()
            return value
        }
        return nil
    }

    @MainActor
    internal func resume(_ resume: NavigationReceiveResumeType) {
        navigator.resume(resume, values: values)
    }

}

extension NavigationSendValues {

    convenience init<T: Hashable>(navigator: Navigator, identifier: String, value: T) {
        self.init(navigator: navigator, value: value, values: [], identifier: identifier)
    }

}
