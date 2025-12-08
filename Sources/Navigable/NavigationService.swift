//
//  NavigationService.swift
//
//  Created by Corey Davis on 4/10/25.
//

import Combine
import SwiftUI

public struct NavigationService: ViewModifier {
    @Binding var navigationState: NavigationState?

    let applyNavigationStack: Bool
    let destinationBuilder: ((AnyRoute) -> AnyView)?
    let destinationOptions: Set<DestinationOptions>
    let sheetPresentationBuilder: ((AnySheet) -> AnyView)?
    let fullScreenCoverPresentationBuilder: ((AnyFullScreenCover) -> AnyView)?

    public enum DestinationOptions: Equatable, Hashable {
        case hideToolbar
        case hideBackButton
        case titleInline
    }

    public func body(content: Content) -> some View {
        if applyNavigationStack {
            NavigationStack(path: bindingForRoutePath()) {
                contentView(content)
                    .navigationBarBackButtonHidden()
                    .toolbar(.hidden)
            }
        } else {
            contentView(content)
        }
    }

    private func contentView(_ content: Content) -> some View {
        content
            .navigationDestination(for: AnyRoute.self) { route in
                decoratedDestination(for: route)
            }
            .sheet(
                item: bindingForSheet(),
                onDismiss: {
                    if navigationState != nil {
                        navigationState = nil
                    }
                }, content: { sheet in
                    sheetPresentationBuilder?(sheet)
                }
            )
            .fullScreenCover(item: bindingForFullScreenCover()) { fullScreenCover in
                fullScreenCoverPresentationBuilder?(fullScreenCover)
            }
            .alert(item: bindingForAlert()) { alert in
                alert.asAlert()
            }
            .confirmationDialog(
                bindingForConfirmationDialog().wrappedValue?.title ?? "",
                isPresented: Binding<Bool>(
                    get: { bindingForConfirmationDialog().wrappedValue != nil },
                    set: { isPresented in
                        if !isPresented {
                            navigationState = nil
                        }
                    }
                ),
                presenting: bindingForConfirmationDialog().wrappedValue
            ) { dialog in
                ForEach(dialog.actions) { action in
                    Button(action.title, role: action.role, action: action.action)
                }
                if let cancel = dialog.cancel {
                    Button(cancel.title, role: cancel.role, action: cancel.action)
                }
            } message: { dialog in
                if let message = dialog.message {
                    Text(message)
                }
            }
    }

    private func decoratedDestination(for route: AnyRoute) -> some View {
        let view = destinationBuilder?(route) ?? EmptyView().eraseToAnyView()
        return view
            .ifModifier(destinationOptions.contains(.hideBackButton)) {
                $0.navigationBarBackButtonHidden()
            }
            .ifModifier(destinationOptions.contains(.hideToolbar)) {
                $0.toolbar(.hidden)
            }
            .ifModifier(destinationOptions.contains(.titleInline)) {
                $0.navigationBarTitleDisplayMode(.inline)
            }
    }

    func bindingForRoutePath() -> Binding<[AnyRoute]> {
        Binding<[AnyRoute]>(
            get: {
                if case .route(let routes) = navigationState { return routes }
                return []
            },
            set: { newValue in
                if !newValue.isEmpty {
                    navigationState = .route(newValue)
                } else {
                    navigationState = nil
                }
            }
        )
    }

    func bindingForSheet() -> Binding<AnySheet?> {
        Binding<AnySheet?>(
            get: {
                if case .sheet(let sheet) = navigationState { return sheet }
                return nil
            },
            set: { newValue in
                if let newState: NavigationState = newValue.map({ .sheet($0) }) {
                    navigationState = newState
                } else {
                    navigationState = nil
                }
            }
        )
    }

    func bindingForFullScreenCover() -> Binding<AnyFullScreenCover?> {
        Binding<AnyFullScreenCover?>(
            get: {
                if case .fullScreenCover(let fullScreenCover) = navigationState { return fullScreenCover }
                return nil
            },
            set: { newValue in
                if let newState: NavigationState = newValue.map({ .fullScreenCover($0) }) {
                    navigationState = newState
                } else {
                    navigationState = nil
                }
            }
        )
    }

    func bindingForAlert() -> Binding<AnyAlert?> {
        Binding<AnyAlert?>(
            get: {
                if case let .alert(alert) = navigationState {
                    return alert
                }
                return nil
            },
            set: { newValue in
                if let newState: NavigationState = newValue.map({ .alert($0) }) {
                    navigationState = newState
                } else {
                    navigationState = nil
                }
            }
        )
    }

    func bindingForConfirmationDialog() -> Binding<AnyConfirmationDialog?> {
        Binding<AnyConfirmationDialog?>(
            get: {
                if case .confirmationDialog(let dialog) = navigationState { return dialog }
                return nil
            },
            set: { newValue in
                if let newState = newValue.map({ NavigationState.confirmationDialog($0) }) {
                    navigationState = newState
                } else {
                    navigationState = nil
                }
            }
        )
    }
}

extension View {
    @ViewBuilder
    fileprivate func ifModifier<Content: View>(
        _ condition: Bool,
        modifier: (Self) -> Content
    ) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
}
