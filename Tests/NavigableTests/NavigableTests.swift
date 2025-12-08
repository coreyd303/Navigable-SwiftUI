@testable import Navigable
import Testing
import SwiftUI

struct NavigableTests {
    @Test("should replace navigationState when set through bindings")
    @MainActor
    func replacesExistingStateWithDifferentState() {
        var navigationState: NavigationState? = .sheet(MockSheet.root.asAnySheet())

        let sut = NavigationService(
            navigationState: Binding(
                get: { navigationState },
                set: { navigationState = $0 }
            ),
            applyNavigationStack: true,
            destinationBuilder: nil,
            destinationOptions: [],
            sheetPresentationBuilder: nil,
            fullScreenCoverPresentationBuilder: nil
        )

        let cover = MockFullScreenCover.root.asAnyFullScreenCover()
        sut.bindingForFullScreenCover().wrappedValue = cover

        #expect(navigationState == .fullScreenCover(cover))
    }

    @Test("should only allow one state at a time")
    @MainActor
    func replacesExistingStateWithNewState() {
        var navigationState: NavigationState? = .sheet(MockSheet.root.asAnySheet())

        let sut = NavigationService(
            navigationState: Binding(
                get: { navigationState },
                set: { navigationState = $0 }
            ),
            applyNavigationStack: true,
            destinationBuilder: nil,
            destinationOptions: [],
            sheetPresentationBuilder: nil,
            fullScreenCoverPresentationBuilder: nil
        )

        let newSheet = MockSheet.detail(0)
        sut.bindingForSheet().wrappedValue = newSheet.asAnySheet()

        #expect(navigationState == .sheet(newSheet.asAnySheet()))
    }

    @Test("should set route state when assigning non-empty path")
    @MainActor
    func setsRouteStateWithNonEmptyPath() {
        var navigationState: NavigationState? = nil

        let sut = NavigationService(
            navigationState: Binding(
                get: { navigationState },
                set: { navigationState = $0 }
            ),
            applyNavigationStack: true,
            destinationBuilder: nil,
            destinationOptions: [],
            sheetPresentationBuilder: nil,
            fullScreenCoverPresentationBuilder: nil
        )

        let routes: [AnyRoute] = [
            MockRoute.root.asAnyRoute(),
            MockRoute.detail(1).asAnyRoute()
        ]

        sut.bindingForRoutePath().wrappedValue = routes

        #expect(navigationState == .route(routes))
    }

    @Test("should set alert when using alert binding")
    @MainActor
    func setsAlertViaBinding() {
        var navigationState: NavigationState? = nil

        let sut = NavigationService(
            navigationState: Binding(
                get: { navigationState },
                set: { navigationState = $0 }
            ),
            applyNavigationStack: true,
            destinationBuilder: nil,
            destinationOptions: [],
            sheetPresentationBuilder: nil,
            fullScreenCoverPresentationBuilder: nil
        )

        let alert = AnyAlert(title: "Some Alert", primaryButton: .cancel())
        sut.bindingForAlert().wrappedValue = alert

        #expect(navigationState == .alert(alert))
    }

    @Test("should replace alert with a new state when assigned through binding")
    @MainActor
    func replacesAlertWithNewState() {
        let alert = AnyAlert(title: "Some Alert", primaryButton: .cancel())
        var navigationState: NavigationState? = .alert(alert)

        let sut = NavigationService(
            navigationState: Binding(
                get: { navigationState },
                set: { navigationState = $0 }
            ),
            applyNavigationStack: true,
            destinationBuilder: nil,
            destinationOptions: [],
            sheetPresentationBuilder: nil,
            fullScreenCoverPresentationBuilder: nil
        )

        let sheet = MockSheet.root.asAnySheet()
        sut.bindingForSheet().wrappedValue = sheet

        #expect(navigationState == .sheet(sheet))
    }

    @Test("should clear alert when alert binding is set to nil")
    @MainActor
    func clearsAlertOnDismiss() {
        var navigationState: NavigationState? = .alert(
            .init(title: "Some Alert", primaryButton: .cancel())
        )

        let sut = NavigationService(
            navigationState: Binding(
                get: { navigationState },
                set: { navigationState = $0 }
            ),
            applyNavigationStack: true,
            destinationBuilder: nil,
            destinationOptions: [],
            sheetPresentationBuilder: nil,
            fullScreenCoverPresentationBuilder: nil
        )

        sut.bindingForAlert().wrappedValue = nil

        #expect(navigationState == nil)
    }

    @Test("should set confirmationDialog via binding")
    @MainActor
    func setsConfirmationDialogViaBinding() {
        var navigationState: NavigationState? = nil

        let sut = NavigationService(
            navigationState: Binding(
                get: { navigationState },
                set: { navigationState = $0 }
            ),
            applyNavigationStack: true,
            destinationBuilder: nil,
            destinationOptions: [],
            sheetPresentationBuilder: nil,
            fullScreenCoverPresentationBuilder: nil
        )

        let dialog = AnyConfirmationDialog(
            title: "Confirm Action",
            message: "Are you sure?",
            actions: [
                .init(title: "Yes", role: .none, action: {}),
                .init(title: "No", role: .cancel, action: {})
            ],
            cancel: .init(title: "Cancel", role: .cancel, action: {})
        )

        sut.bindingForConfirmationDialog().wrappedValue = dialog

        #expect(navigationState == .confirmationDialog(dialog))
    }

    @Test("should clear confirmationDialog when set to nil")
    @MainActor
    func clearsConfirmationDialogOnDismiss() {
        let dialog = AnyConfirmationDialog(
            title: "Title",
            message: "Confirm?",
            actions: [],
            cancel: nil
        )

        var navigationState: NavigationState? = .confirmationDialog(dialog)

        let sut = NavigationService(
            navigationState: Binding(
                get: { navigationState },
                set: { navigationState = $0 }
            ),
            applyNavigationStack: true,
            destinationBuilder: nil,
            destinationOptions: [],
            sheetPresentationBuilder: nil,
            fullScreenCoverPresentationBuilder: nil
        )

        sut.bindingForConfirmationDialog().wrappedValue = nil

        #expect(navigationState == nil)
    }

    @Test("should clear navigation state when state is dismissed via binding")
    @MainActor
    func clearsSheetStateOnDismiss() {
        var navigationState: NavigationState? = .sheet(MockSheet.root.asAnySheet())

        let sut = NavigationService(
            navigationState: Binding(
                get: { navigationState },
                set: { navigationState = $0 }
            ),
            applyNavigationStack: true,
            destinationBuilder: nil,
            destinationOptions: [],
            sheetPresentationBuilder: nil,
            fullScreenCoverPresentationBuilder: nil
        )

        // Simulate dismiss
        sut.bindingForSheet().wrappedValue = nil

        #expect(navigationState == nil)
    }

    @Test("should clear route state when binding is assigned an empty array")
    @MainActor
    func clearsRouteStateWhenPathIsEmpty() {
        let route1 = MockRoute.detail(0).asAnyRoute()
        let route2 = MockRoute.root.asAnyRoute()
        var navigationState: NavigationState? = .route([route1, route2])

        let sut = NavigationService(
            navigationState: Binding(
                get: { navigationState },
                set: { navigationState = $0 }
            ),
            applyNavigationStack: true,
            destinationBuilder: nil,
            destinationOptions: [],
            sheetPresentationBuilder: nil,
            fullScreenCoverPresentationBuilder: nil
        )

        sut.bindingForRoutePath().wrappedValue = []

        #expect(navigationState == nil)
    }
}
