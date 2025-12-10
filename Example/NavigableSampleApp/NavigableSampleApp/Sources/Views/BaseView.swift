//
//  ContentView.swift
//  NavigableSampleApp
//
//  Created by Corey Davis on 12/10/25.
//

import SwiftUI
import Navigable

// MARK: Root View

struct BaseView: View {
    @State var viewModel = BaseViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Button("Push Route") {
                viewModel.push(Routez.route1)
            }
        }
        .buttonStyle(.automatic)
        .applyNavigation(
            navigationState: $viewModel.navigationState,
            isRootNavigator: true,
            destinationBuilder: viewModel.destinationBuilder
        )
    }
}

#Preview {
    BaseView()
}
