//
//  NavigationSample.swift
//
//  Created by Corey Davis on 6/6/25.
//

//#if DEBUG
//import SwiftUI
//
//// MARK: Root View
//
//struct BaseView: View {
//    @State var viewModel = BaseViewModel()
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Button("Push Route") {
//                viewModel.push(Routez.route1)
//            }
//        }
//        .buttonStyle(.borderedProminent)
//        .applyNavigation(
//            navigationState: $viewModel.navigationState,
//            isRootNavigator: true,
//            destinationBuilder: viewModel.destinationBuilder
//        )
//    }
//}
//
//#Preview {
//    BaseView()
//}
//
//enum Routez: Routable {
//    case route1
//}
//
//struct AView: NavigableView {
//    @State var navigationState: NavigationState?
//
//    var body: some View {
//        Text("Hello World")
//            .applyNavigation(
//                navigationState: $navigationState,
//                isRootNavigator: true,
//                destinationBuilder: { route in
//                    guard let route = route.base as? Routez else {
//                        preconditionFailure()
//                    }
//
//                    switch route {
//                    case .route1:
//                        return RouteView {
//                            self.pop(using: $navigationState)
//                        }
//                        .eraseToAnyView()
//                    }
//                },
//                destinationOptions: [],
//                sheetPresentationBuilder: { sheet in
//                    guard let sheet = sheet.base as? Sheetz else {
//                        preconditionFailure()
//                    }
//
//                    switch sheet {
//                    case .sheet1:
//                        return SheetView(
//                            title: "Sheet View 1",
//                            dismissView: {
//                                self.enqueue {
//                                    self.present(Sheetz.sheet2, using: <#Binding<NavigationState?>#>)
//                                }
//                            }
//                        )
//                        .eraseToAnyView()
//                    case .sheet2:
//                        ...someOtherView
//                    case .sheet3:
//                        ...yetAnotherView
//                    }
//
//                    EmptyView().eraseToAnyView()
//                },
//                fullScreenCoverPresentationBuilder: { cover in
//                    ...presentCover
//                }
//            )
//    }
//}
//
//@Observable
//final class BaseViewModel: Navigable {
//    override func destination(for route: any Routable) -> AnyView {
//        guard let route = route as? Routez else {
//            return EmptyView().eraseToAnyView()
//        }
//
//        switch route {
//        case .route1:
//            return RouteView {
//                self.pop()
//            }
//            .eraseToAnyView()
//        }
//    }
//}
//
//// MARK: - Route View
//
//struct RouteView: View {
//    @State var viewModel = RouteViewModel()
//    let dismissView: () -> Void
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Route View")
//
//            Button("Present Sheet 1") {
//                viewModel.present(Sheetz.sheet1)
//            }
//
//            Button("Dismiss Route") {
//                dismissView()
//            }
//        }
//        .buttonStyle(.primaryV2)
//        .applyNavigation(
//            navigationState: $viewModel.navigationState,
//            isRootNavigator: false,
//            sheetPresentationBuilder: viewModel.sheetPresentationBuilder
//        )
//    }
//}
//
//enum Sheetz: Sheetable {
//    case sheet1
//    case sheet2
//    case sheet3
//}
//
//final class RouteViewModel: Navigable {
//    override func sheetPresentation(for sheet: any Sheetable) -> AnyView {
//        guard let sheet = sheet as? Sheetz else {
//            return EmptyView().eraseToAnyView()
//        }
//
//        switch sheet {
//        case .sheet1:
//            return SheetView(
//                title: "Sheet View 1",
//                dismissView: {
//                    self.enqueue {
//                        self.present(Sheetz.sheet2)
//                    }
//                }
//            )
//            .eraseToAnyView()
//        case .sheet2:
//            return SheetView(title: "Sheet View 2") {
//                self.dismissPresentationOrDisplay()
//            }
//            .eraseToAnyView()
//        case .sheet3:
//            return AnotherSheetView(
//                dismissView: {
//                    self.dismissPresentationOrDisplay()
//                },
//                confirmationAction: {
//                    // take some other action based on confirmation...
//                    self.dismissPresentationOrDisplay()
//                }
//            )
//            .eraseToAnyView()
//        }
//    }
//}
//
//// MARK: Sheet View
//
//struct SheetView: View {
//    @State var viewModel = RouteViewModel()
//    let title: String
//    let dismissView: () -> Void
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text(title)
//
//            Button("Present another sheet") {
//                viewModel.present(Sheetz.sheet3)
//            }
//
//            Button("Dismiss \(title)") {
//                dismissView()
//            }
//        }
//        .buttonStyle(.primaryV2)
//        .applyNavigation(
//            navigationState: $viewModel.navigationState,
//            isRootNavigator: false,
//            sheetPresentationBuilder: viewModel.sheetPresentationBuilder
//        )
//    }
//}
//
//// MARK: Another Sheet View
//
//struct AnotherSheetView: NavigableView {
//    @State var navigationState: NavigationState?
//    let dismissView: () -> Void
//    let confirmationAction: () -> Void
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Another Sheet View")
//
//            Button("Confirm?") {
//                display(
//                    confirmationDialog,
//                    using: $navigationState
//                )
//            }
//        }
//        .buttonStyle(.primaryV2)
//        .applyNavigation(
//            navigationState: $navigationState,
//            isRootNavigator: false
//        )
//    }
//
//    private var confirmationDialog: AnyConfirmationDialog {
//        AnyConfirmationDialog(
//            title: "Are you sure?",
//            message: "Just checking!",
//            actions: [
//                AnyConfirmationDialog.DialogAction(
//                    title: "Yes!",
//                    action: {
//                        confirmationAction()
//                    }
//                ),
//                AnyConfirmationDialog.DialogAction(
//                    title: "No!",
//                    role: .cancel,
//                    action: {
//                        display(alert, using: $navigationState)
//                    }
//                )
//            ]
//        )
//    }
//
//    private var alert: AnyAlert {
//        AnyAlert(
//            style: .system(
//                title: "Boo Hoo",
//                message: "That's too bad!",
//                primaryButton: .cancel(),
//                secondaryButton: nil
//            )
//        )
//    }
//}
//#endif
