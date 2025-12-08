//
//  MockNavigationState.swift
//
//  Created by Corey Davis on 4/14/25.
//

import Foundation
import Navigable

enum MockRoute: Routable {
    case root
    case detail(Int)
}

enum MockSheet: Sheetable {
    case root
    case detail(Int)
}

enum MockFullScreenCover: Coverable {
    case root
    case detail(Int)
}
