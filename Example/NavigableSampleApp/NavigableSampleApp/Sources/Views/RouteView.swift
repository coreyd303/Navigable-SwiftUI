//
//  RouteView.swift
//  NavigableSampleApp
//
//  Created by Corey Davis on 12/10/25.
//

import SwiftUI
import Navigable

struct RouteView: View {
    @State var viewModel = RouteViewModel()
    let title: String
    let pushRoute: (Routez) -> Void
    let dismissView: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Route View \(title)")

            if title == "One" {
                Button("Push another route") {
                    pushRoute(.route2)
                }
            }

            Button("Present Sheet 1") {
                viewModel.present(Sheetz.sheet1)
            }

            Button("Dismiss Route") {
                dismissView()
            }
        }
        .buttonStyle(.automatic)
        .applyNavigation(
            navigationState: $viewModel.navigationState,
            isRootNavigator: false,
            destinationBuilder: viewModel.destinationBuilder,
            sheetPresentationBuilder: viewModel.sheetPresentationBuilder
//          full screen covers work the same as sheets, you just have to implement the builder
//            fullScreenCoverPresentationBuilder: viewModel.fullScreenCoverPresentationBuilder
        )
    }
}
