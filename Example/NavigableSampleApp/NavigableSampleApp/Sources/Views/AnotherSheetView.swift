//
//  AnotherSheetView.swift
//  NavigableSampleApp
//
//  Created by Corey Davis on 12/10/25.
//

import SwiftUI
import Navigable

// This view implemented the simplified NavigableView pattern,
// this is a synthesized support tool that allow you to handle simple navigation needs with out the weight of a viewModel
// in this example we are using it to handle
struct AnotherSheetView: NavigableView {
    @State var navigationState: NavigationState?
    let dismissView: () -> Void
    let confirmationAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Another Sheet View")

            Button("Confirm?") {
                display(
                    confirmationDialog,
                    using: $navigationState
                )
            }
        }
        .buttonStyle(.automatic)
        .applyNavigation(
            navigationState: $navigationState,
            isRootNavigator: false
        )
    }

    private var confirmationDialog: AnyConfirmationDialog {
        AnyConfirmationDialog(
            title: "Are you sure?",
            message: "Just checking!",
            actions: [
                AnyConfirmationDialog.DialogAction(
                    title: "Yes! (dismiss view)",
                    action: {
                        confirmationAction()
                    }
                ),
                AnyConfirmationDialog.DialogAction(
                    title: "No! (alert)",
                    role: .cancel,
                    action: {
                        enqueue(
                            navigation: {
                                display(alert, using: $navigationState)
                            },
                            using: $navigationState
                        )
                    }
                )
            ]
        )
    }

    private var alert: AnyAlert {
        AnyAlert(
            title: "Boo Hoo",
            primaryButton: .cancel()
        )
    }
}
