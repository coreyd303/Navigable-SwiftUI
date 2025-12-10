//
//  RouteViewModel.swift
//  NavigableSampleApp
//
//  Created by Corey Davis on 12/10/25.
//

import SwiftUI
import Navigable

enum Sheetz: Sheetable {
    case sheet1
    case sheet2
    case sheet3
}

final class RouteViewModel: Navigable {
    override func sheetPresentation(for sheet: any Sheetable) -> AnyView {
        guard let sheet = sheet as? Sheetz else {
            return EmptyView().eraseToAnyView()
        }

        switch sheet {
        case .sheet1:
            return SheetView(
                title: "Sheet View 1",
                dismissView: { andDisplay in
                    if andDisplay {
                        self.enqueue {
                            self.present(Sheetz.sheet2)
                        }
                    } else {
                        self.dismissPresentationOrDisplay()
                    }
                }
            )
            .eraseToAnyView()
        case .sheet2:
            return SheetView(title: "Sheet View 2") { _ in
                self.dismissPresentationOrDisplay()
            }
            .eraseToAnyView()
        case .sheet3:
            return AnotherSheetView(
                dismissView: {
                    self.dismissPresentationOrDisplay()
                },
                confirmationAction: {
                    // take some other action based on confirmation...
                    self.dismissPresentationOrDisplay()
                }
            )
            .eraseToAnyView()
        }
    }
}
