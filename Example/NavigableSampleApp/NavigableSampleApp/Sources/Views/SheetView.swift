//
//  SheetView.swift
//  NavigableSampleApp
//
//  Created by Corey Davis on 12/10/25.
//

import SwiftUI
import Navigable

struct SheetView: View {
    @State var viewModel = RouteViewModel()
    let title: String
    let dismissView: (_ andDisplay: Bool) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)

            Button("Present another sheet") {
                viewModel.present(Sheetz.sheet3)
            }

            Button("Dismiss and display a new sheet") {
                dismissView(true)
            }

            Button("Dismiss \(title)") {
                dismissView(false)
            }
        }
        .buttonStyle(.automatic)
        .applyNavigation(
            navigationState: $viewModel.navigationState,
            isRootNavigator: false,
            sheetPresentationBuilder: viewModel.sheetPresentationBuilder
        )
    }
}
