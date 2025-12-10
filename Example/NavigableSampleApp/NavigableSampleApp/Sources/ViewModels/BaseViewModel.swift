//
//  BaseViewModel.swift
//  NavigableSampleApp
//
//  Created by Corey Davis on 12/10/25.
//

import SwiftUI
import Navigable

enum Routez: Routable {
    case route1
    case route2
}

@Observable
final class BaseViewModel: Navigable {
    override func destination(for route: any Routable) -> AnyView {
        guard let route = route as? Routez else {
            return EmptyView().eraseToAnyView()
        }

        switch route {
        case .route1:
            return RouteView(
                title: "One",
                pushRoute: {
                    // keep in mind this is one way to handle this,
                    // there are possibly others depending on your use case,
                    // feel free to be creative!
                    self.push($0)
                },
                dismissView: {
                    self.pop()
                }
            )
            .eraseToAnyView()
        case .route2:
            return RouteView(
                title: "Two",
                pushRoute: { _ in
                    // you could keep pushing more views if you wanted to!
                },
                dismissView: {
                    self.pop()
                }
            )
            .eraseToAnyView()
        }
    }
}
