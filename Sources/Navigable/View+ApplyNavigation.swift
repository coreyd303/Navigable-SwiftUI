//
//  View+ApplyNavigation.swift
//
//  Created by Corey Davis on 3/31/25.
//

import SwiftUI

extension View {

    /// Applies a `NavigationService` to this view to drive navigation, sheet, and full-screen
    /// cover presentation from a single observable `NavigationState`.
    ///
    /// Call this once at the root of a flow (with `isRootNavigator == true`) to wrap the
    /// receiver in a `NavigationStack`. Downstream child views should pass
    /// `isRootNavigator == false` so they participate in the same navigation graph without
    /// creating nested stacks.
    ///
    /// If you don’t provide any of the builder closures, the service falls back to its
    /// default resolvers (if available). You can override any subset to customize rendering
    /// for routes, sheets, or full-screen covers.
    ///
    /// - Parameters:
    ///   - navigationState: A binding to the current `NavigationState?` that describes the
    ///     desired navigation destination(s) and presentations. Set this to update the UI; set
    ///     it to `nil` to clear presentations and pop to the root as appropriate.
    ///   - isRootNavigator: Pass `true` exactly once per workflow to install a
    ///     `NavigationStack` around the receiver. Pass `false` for all descendant views so
    ///     they share the same stack. Having more than one root navigator in a workflow is
    ///     unsupported and will result in nested stacks.
    ///   - destinationBuilder: Optional resolver that converts an `AnyRoute` into the view
    ///     to push inside the `NavigationStack`. Return an `AnyView` for the route, or
    ///     `nil` to defer to the service’s default route resolver.
    ///   - destinationOptions: Options that affect how destination pushes are performed,
    ///     such as animation or duplicate-push behavior (see
    ///     `NavigationService.DestinationOptions` for details). Defaults to an empty set.
    ///   - sheetPresentationBuilder: Optional resolver that converts an `AnySheet` into the
    ///     view to present modally as a sheet. Return an `AnyView` for the sheet content, or
    ///     `nil` to use the default sheet resolver.
    ///   - fullScreenCoverPresentationBuilder: Optional resolver that converts an
    ///     `AnyFullScreenCover` into the view to present as a full-screen cover. Return an
    ///     `AnyView` for the cover content, or `nil` to use the default cover resolver.
    /// - Returns: A view modified with `NavigationService` that observes `navigationState`
    ///   and updates navigation pushes, sheets, and full-screen covers accordingly.
    ///
    /// - Important: You should have **one and only one** view with `isRootNavigator == true`
    ///   per navigation workflow. Child views should forward the same binding for the NavigationStack and set
    ///   `isRootNavigator == false`.
    ///   Keep in mind however, that if your child views have possible presentations that are separate from the Navigation Stack
    ///   those should be managed with new NavigationState that is specific to the child views needs.
    ///
    /// - SeeAlso: `NavigationState`, `AnyRoute`, `AnySheet`, `AnyFullScreenCover`,
    ///   `NavigationService.DestinationOptions`.
    public func applyNavigation(
        navigationState: Binding<NavigationState?>,
        isRootNavigator: Bool,
        destinationBuilder: ((AnyRoute) -> AnyView)? = nil,
        destinationOptions: Set<NavigationService.DestinationOptions> = [],
        sheetPresentationBuilder: ((AnySheet) -> AnyView)? = nil,
        fullScreenCoverPresentationBuilder: ((AnyFullScreenCover) -> AnyView)? = nil
    ) -> some View {
        modifier(
            NavigationService(
                navigationState: navigationState,
                applyNavigationStack: isRootNavigator,
                destinationBuilder: destinationBuilder,
                destinationOptions: destinationOptions,
                sheetPresentationBuilder: sheetPresentationBuilder,
                fullScreenCoverPresentationBuilder: fullScreenCoverPresentationBuilder
            )
        )
    }

    public func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
