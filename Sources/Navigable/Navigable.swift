//
//  Navigable.swift
//
//  Created by Corey Davis on 3/12/25.
//

import Foundation
import SwiftUI

/// A shared navigation interface for both `View`-based and class-based navigation coordinators.
///
/// `NavigableBase` defines the minimal contract required to participate in the navigation system,
/// including routing, sheet presentation, and full-screen cover support.
///
/// 🚫 Do not conform to `NavigableBase` directly.
/// 👉 Instead, use `Navigable` for class-based navigation logic, or `NavigableView` for SwiftUI views.
@MainActor
public protocol NavigableBase {
    /// The active navigation state, representing a route, sheet, full-screen cover, alert, or confirmation dialog.
    ///
    /// Types conforming to this protocol are responsible for reading and mutating this property
    /// to drive navigation within the UI.
    var navigationState: NavigationState? { get set }

    /// Resolves a SwiftUI view for the given `Routable` value.
    ///
    /// - Parameter route: The strongly-typed route to navigate to.
    /// - Returns: A type-erased SwiftUI view representing the destination.
    func destination(for route: any Routable) -> AnyView

    /// Resolves a SwiftUI view to present as a sheet for the given `Sheetable` value.
    ///
    /// - Parameter sheet: The strongly-typed sheet to present.
    /// - Returns: A type-erased SwiftUI view to display in a `.sheet` presentation.
    func sheetPresentation(for sheet: any Sheetable) -> AnyView

    /// Resolves a SwiftUI view to present as a full-screen cover for the given `Coverable` value.
    ///
    /// - Parameter fullScreenCover: The full-screen cover to present.
    /// - Returns: A type-erased SwiftUI view to display in a `.fullScreenCover` presentation.
    func fullScreenCoverPresentation(for fullScreenCover: any Coverable) -> AnyView

    /// 🚫 Do not conform to `NavigableBase` directly.
    ///
    /// This static requirement is used to enforce restricted conformance.
    /// Use `Navigable` or `NavigableView` instead.
    static var __do_not_conform_to_NavigableBase_directly: Never { get }
}

extension NavigableBase {
    /// Default fallback implementation that crashes at runtime if not overridden.
    ///
    /// Subclasses or conformers must implement this if they support route navigation.
    func destination(for route: any Routable) -> AnyView {
        fatalError("❌ ERROR: 'destination(for:)' must be implemented in \(Self.self) if route navigation is used.")
    }

    /// Default fallback implementation that crashes at runtime if not overridden.
    ///
    /// Subclasses or conformers must implement this if they support sheet presentation.
    func sheetPresentation(for sheet: any Sheetable) -> AnyView {
        fatalError("❌ ERROR: 'sheetPresentation(for:)' must be implemented in \(Self.self) if sheets are used.")
    }

    /// Default fallback implementation that crashes at runtime if not overridden.
    ///
    /// Subclasses or conformers must implement this if they support full-screen covers.
    func fullScreenCoverPresentation(for fullScreenCover: any Coverable) -> AnyView {
        fatalError("❌ ERROR: 'fullScreenCoverPresentation(for:)' must be implemented in \(Self.self) if full-screen covers are used.")
    }
}

// swiftlint:disable all
// swiftformat:disable all
extension NavigableBase {
    /// A helper closure that resolves views from `AnyRoute` values.
    ///
    /// This is typically used by navigation modifiers to bridge from type-erased routes.
    public var destinationBuilder: ((AnyRoute) -> AnyView) {
        { anyRoute in
            destination(for: anyRoute.base)
        }
    }

    /// A helper closure that resolves views from `AnySheet` values.
    ///
    /// Used to bridge SwiftUI's `.sheet` modifier to the appropriate presentation logic.
    public var sheetPresentationBuilder: ((AnySheet) -> AnyView) {
        { anySheet in
            sheetPresentation(for: anySheet.base)
        }
    }

    /// A helper closure that resolves views from `AnyFullScreenCover` values.
    ///
    /// Used to bridge SwiftUI's `.fullScreenCover` modifier to the appropriate presentation logic.
    public var fullScreenCoverPresentationBuilder: ((AnyFullScreenCover) -> AnyView) {
        { anyCover in
            fullScreenCoverPresentation(for: anyCover.base)
        }
    }
}
// swiftlint:enable all
// swiftformat:enable all

/// A base class for imperative navigable reference type objects that participate in the navigation system.
///
/// 🚫 You should **not** conform to `NavigableBase` directly.
/// ✅ Instead, subclass `Navigable` for controller-style navigation logic,
/// or conform to `NavigableView` if you are working in SwiftUI.
///
/// This class provides a default `navigationState` property and synthesized helpers for driving navigation imperatively.
@MainActor
@Observable
open class Navigable: NavigableBase {
    /// 🚫 Do **not** conform to `NavigableBase` directly.
    ///
    /// This static requirement is used to enforce that only `Navigable` and `NavigableView` are allowed
    /// to fulfill the `NavigableBase` contract.
    ///
    /// If you see a compiler error about this, make sure you are using `NavigableView` or `Navigable`,
    /// not `NavigableBase` directly.
    public static var __do_not_conform_to_NavigableBase_directly: Never {
        fatalError("Do not conform to NavigableBase directly")
    }

    /// The current navigation state. This drives what is presented in the view layer:
    /// - a route stack (`.route`)
    /// - a modal sheet (`.sheet`)
    /// - a full screen cover (`.fullScreenCover`)
    /// - an alert (`.alert`)
    /// - a confirmation dialog (`.confirmationDialog`)
    public var navigationState: NavigationState?

    public init() {}

    // MARK: - Synthesized Convenience Methods

    /// Pushes a single route onto the current navigation stack.
    public func push(_ route: any Routable) {
        let anyRoute = route.asAnyRoute()
        switch navigationState {
        case .route(var routes):
            routes.append(anyRoute)
            navigationState = .route(routes)
        default:
            navigationState = .route([anyRoute])
        }
    }

    /// Pushes multiple routes onto the current navigation stack.
    public func push(_ routes: [any Routable]) {
        let anyRoutes = routes.map { $0.asAnyRoute() }
        switch navigationState {
        case .route(let existing):
            navigationState = .route(existing + anyRoutes)
        default:
            navigationState = .route(anyRoutes)
        }
    }

    /// Pops the last route from the current navigation stack.
    public func pop() {
        guard case .route(var routes) = navigationState else { return }
        _ = routes.popLast()
        navigationState = routes.isEmpty ? nil : .route(routes)
    }

    /// Pops the route stack to the specified index.
    ///
    /// - Parameter index: The number of routes to retain (0-based).
    public func popTo(index: Int) {
        guard case .route(let routes) = navigationState,
              index > 0, index < routes.count else { return }
        navigationState = .route(Array(routes.prefix(index)))
    }

    /// Pops the navigation stack to the root route (if it exists).
    public func popToRoot() {
        guard case .route(let routes) = navigationState,
              let first = routes.first else { return }
        navigationState = .route([first])
    }

    /// Replaces the last route on the stack with a new route.
    public func swap(_ route: any Routable) {
        let anyRoute = route.asAnyRoute()
        switch navigationState {
        case .route(var routes):
            _ = routes.popLast()
            routes.append(anyRoute)
            navigationState = .route(routes)
        default:
            navigationState = .route([anyRoute])
        }
    }

    /// Presents a full screen cover.
    public func present(_ fullScreenCover: any Coverable) {
        navigationState = .fullScreenCover(fullScreenCover.asAnyFullScreenCover())
    }

    /// Presents a modal sheet.
    public func present(_ sheet: any Sheetable) {
        navigationState = .sheet(sheet.asAnySheet())
    }

    /// Displays an alert.
    public func display(_ alert: AnyAlert) {
        navigationState = .alert(alert)
    }

    /// Displays a confirmation dialog.
    public func display(_ dialog: AnyConfirmationDialog) {
        navigationState = .confirmationDialog(dialog)
    }

    /// Swap to a new presentation, use this to change the `NavigationState` when you are already presenting or displaying
    ///
    /// - Parameters:
    ///   - action: An action to enque, will be performed after a small delay
    ///   - delay: TimeInterval to delay execution by, defaults to 6/10ths of a second
    public func enqueue(
        navigation action: @escaping () -> Void,
        after delay: TimeInterval = 0
    ) {
        if navigationState != nil {
            dismissPresentationOrDisplay()
        }
        Task {
            try? await Task.sleep(for: .seconds(delay))
            action()
        }
    }

    /// Dismiss a presentation or display state
    public func dismissPresentationOrDisplay() {
        switch navigationState {
        case .route:
            assertionFailure("Attempted to dismiss a modal while a route is active. Use a different method.")
            return
        default:
            navigationState = nil
        }
    }

    // MARK: - Default Implementations (Must be Overridden)

    /// Returns the destination view for a given route.
    ///
    /// Subclasses must override this method if they support route-based navigation.
    open func destination(for route: any Routable) -> AnyView {
        fatalError("❌ ERROR: You must override 'destination(for:)' in \(Self.self) if route navigation is used.")
    }

    /// Returns the sheet view for a given sheet.
    ///
    /// Subclasses must override this method if they support modal sheet presentation.
    open func sheetPresentation(for sheet: any Sheetable) -> AnyView {
        fatalError("❌ ERROR: You must override 'sheetPresentation(for:)' in \(Self.self) if sheets are used.")
    }

    /// Returns the full screen cover view for a given cover.
    ///
    /// Subclasses must override this method if they support full screen cover presentation.
    open func fullScreenCoverPresentation(for fullScreenCover: any Coverable) -> AnyView {
        fatalError("❌ ERROR: You must override 'fullScreenCoverPresentation(for:)' in \(Self.self) if full-screen covers are used.")
    }

    /// Returns the alert to be shown for a given `AnyAlert` value.
    ///
    /// Subclasses must override this method if they use alerts in navigation.
    open func alert(for alert: AnyAlert) -> AnyAlert {
        fatalError("❌ ERROR: 'alert(for:)' must be implemented in \(Self.self) if alerts are used.")
    }

    /// Returns the confirmation dialog to be shown for a given `AnyConfirmationDialog` value.
    ///
    /// Subclasses must override this method if they use confirmation dialogs in navigation.
    open func confirmationDialog(for dialog: AnyConfirmationDialog) -> AnyConfirmationDialog {
        fatalError("❌ ERROR: 'confirmationDialog(for:)' must be implemented in \(Self.self) if confirmation dialogs are used.")
    }
}

/// A convenience protocol for SwiftUI Views that participate in the navigation system.
///
/// 🚫 You should **not** conform to `NavigableBase` directly.
/// ✅ Instead, conform to `NavigableView` (for SwiftUI views) or use `Navigable` (for class-based types).
///
/// This protocol provides the required static enforcement key to satisfy the `NavigableBase` contract,
/// and supplies a suite of default imperative navigation helpers that operate on a `Binding<NavigationState?>`.
@MainActor
public protocol NavigableView: NavigableBase, View {}

// swiftformat:disable all
// swiftlint:disable all
public extension NavigableView {
    /// 🚫 Do **not** conform to `NavigableBase` directly.
    ///
    /// This static requirement enforces the intended conformance pathway.
    /// If you see a compiler error related to this, ensure you're using `NavigableView` or `Navigable`,
    /// not `NavigableBase` directly.
    static var __do_not_conform_to_NavigableBase_directly: Never {
        fatalError("Do not conform to NavigableBase directly")
    }

    // MARK: - Navigation Actions

    /// Pushes a single route onto the navigation stack.
    ///
    /// - Parameters:
    ///   - route: The route to push.
    ///   - navigationState: A binding to the navigation state that drives view transitions.
    func push(_ route: any Routable, using navigationState: Binding<NavigationState?>) {
        navigationState.wrappedValue.appendRoute(route)
    }

    /// Pushes multiple routes onto the navigation stack.
    ///
    /// - Parameters:
    ///   - routes: An array of routes to push in order.
    ///   - navigationState: A binding to the navigation state that drives view transitions.
    func push(_ routes: [any Routable], using navigationState: Binding<NavigationState?>) {
        navigationState.wrappedValue.appendRoutes(routes)
    }

    /// Pops the last route off the navigation stack.
    ///
    /// - Parameter navigationState: A binding to the navigation state to modify.
    func pop(using navigationState: Binding<NavigationState?>) {
        if case var .route(routes) = navigationState.wrappedValue {
            _ = routes.popLast()
            navigationState.wrappedValue = routes.isEmpty ? nil : .route(routes)
        }
    }

    /// Pops the navigation stack to its root (first) route.
    ///
    /// - Parameter navigationState: A binding to the navigation state to modify.
    func popToRoot(using navigationState: Binding<NavigationState?>) {
        if case let .route(routes) = navigationState.wrappedValue, let first = routes.first {
            navigationState.wrappedValue = .route([first])
        }
    }

    /// Replaces the last route on the stack with a new route.
    ///
    /// - Parameters:
    ///   - route: The new route to push.
    ///   - navigationState: A binding to the navigation state to modify.
    func swap(_ route: any Routable, using navigationState: Binding<NavigationState?>) {
        if case var .route(routes) = navigationState.wrappedValue {
            _ = routes.popLast()
            push(route, using: navigationState)
        }
    }

    // MARK: - Modal Presentation

    /// Presents a full screen cover.
    ///
    /// - Parameters:
    ///   - fullScreenCover: The coverable to display.
    ///   - navigationState: A binding to the navigation state to update.
    func present(_ fullScreenCover: any Coverable, using navigationState: Binding<NavigationState?>) {
        navigationState.wrappedValue = .fullScreenCover(fullScreenCover.asAnyFullScreenCover())
    }

    /// Presents a modal sheet.
    ///
    /// - Parameters:
    ///   - sheet: The sheet to display.
    ///   - navigationState: A binding to the navigation state to update.
    func present(_ sheet: any Sheetable, using navigationState: Binding<NavigationState?>) {
        navigationState.wrappedValue = .sheet(sheet.asAnySheet())
    }

    // MARK: - Alerts and Confirmation Dialogs

    /// Displays an alert.
    ///
    /// - Parameters:
    ///   - alert: The alert configuration to show.
    ///   - navigationState: A binding to the navigation state to update.
    func display(_ alert: AnyAlert, using navigationState: Binding<NavigationState?>) {
        navigationState.wrappedValue = .alert(alert)
    }

    /// Displays a confirmation dialog.
    ///
    /// - Parameters:
    ///   - dialog: The confirmation dialog configuration to show.
    ///   - navigationState: A binding to the navigation state to update.
    func display(_ dialog: AnyConfirmationDialog, using navigationState: Binding<NavigationState?>) {
        navigationState.wrappedValue = .confirmationDialog(dialog)
    }

    /// Swap to a new presentation, use this to change the `NavigationState` when you are already presenting or displaying
    ///
    /// - Parameters:
    ///   - action: An action to enque, will be performed after a small delay
    ///   - delay: TimeInterval to delay execution by, defaults to 6/10ths of a second
    ///   - navigationState: A binding to the navigation state to update.
    func enqueue(
        navigation action: @escaping () -> Void,
        after delay: TimeInterval = 0.6,
        using navigationState: Binding<NavigationState?>
    ) {
        if navigationState.wrappedValue != nil {
            dismissPresentationOrDisplay(navigationState)
        }
        Task {
            /// We sleep for a short time to allow SwiftUI to catch up
            /// This delay is imperceptable to the user and prevents a nil state collision when transitioning to a new presentation or display
            try? await Task.sleep(for: .seconds(delay))
            action()
        }
    }

    /// Dismiss a presentation or display state
    ///
    /// - Parameters:
    ///   - navigationState: A binding to the navigation state to update.
    func dismissPresentationOrDisplay(_ navigationState: Binding<NavigationState?>) {
        switch navigationState.wrappedValue {
        case .route:
            assertionFailure("Attempted to dismiss a modal while a route is active. Use a different method.")
            return
        default:
            navigationState.wrappedValue = nil
        }
    }
}

public extension NavigableView {
    // MARK: - Default Implementations

    /// Returns the destination view for a given route.
    ///
    /// Subclasses must override this method if they support route-based navigation.
    func destination(for route: any Routable) -> AnyView {
        fatalError("❌ ERROR: You must override 'destination(for:)' in \(Self.self) if route navigation is used.")
    }

    /// Returns the sheet view for a given sheet.
    ///
    /// Subclasses must override this method if they support modal sheet presentation.
    func sheetPresentation(for sheet: any Sheetable) -> AnyView {
        fatalError("❌ ERROR: You must override 'sheetPresentation(for:)' in \(Self.self) if sheets are used.")
    }

    /// Returns the full screen cover view for a given cover.
    ///
    /// Subclasses must override this method if they support full screen cover presentation.
    func fullScreenCoverPresentation(for fullScreenCover: any Coverable) -> AnyView {
        fatalError("❌ ERROR: You must override 'fullScreenCoverPresentation(for:)' in \(Self.self) if full-screen covers are used.")
    }

    /// Returns the alert to be shown for a given `AnyAlert` value.
    ///
    /// Subclasses must override this method if they use alerts in navigation.
    func alert(for alert: AnyAlert) -> AnyAlert {
        fatalError("❌ ERROR: 'alert(for:)' must be implemented in \(Self.self) if alerts are used.")
    }

    /// Returns the confirmation dialog to be shown for a given `AnyConfirmationDialog` value.
    ///
    /// Subclasses must override this method if they use confirmation dialogs in navigation.
    func confirmationDialog(for dialog: AnyConfirmationDialog) -> AnyConfirmationDialog {
        fatalError("❌ ERROR: 'confirmationDialog(for:)' must be implemented in \(Self.self) if confirmation dialogs are used.")
    }
}
// swiftformat:enable all
// swiftlint:enable all
