//
//  NavigationState.swift
//
//  Created by Corey Davis on 3/31/25.
//

import NavigableSupport
import SwiftUI

public enum NavigationState: Equatable {
    case route([AnyRoute])
    case sheet(AnySheet)
    case fullScreenCover(AnyFullScreenCover)
    case alert(AnyAlert)
    case confirmationDialog(AnyConfirmationDialog)
}

extension Optional where Wrapped == NavigationState {
    mutating func appendRoute(_ route: some Routable) {
        appendRoutes([route])
    }

    mutating func appendRoutes(_ routes: [any Routable]) {
        let anyRoutes = routes.map { $0.asAnyRoute() }

        switch self {
        case .route(var path):
            path.append(contentsOf: anyRoutes)
            self = .route(path)
        default:
            self = .route(anyRoutes)
        }
    }
}

public protocol Routable: HashValueIdentifiable {
    func asAnyRoute() -> AnyRoute
    func view() -> AnyView
}

extension Routable {
    public func asAnyRoute() -> AnyRoute {
        AnyRoute(base: self)
    }

    public func view() -> AnyView {
        preconditionFailure("view constructor must be implemented")
    }
}

public protocol Sheetable: HashValueIdentifiable {
    func asAnySheet() -> AnySheet
    func view() -> AnyView
}

extension Sheetable {
    public func asAnySheet() -> AnySheet {
        AnySheet(base: self)
    }

    public func view() -> AnyView {
        preconditionFailure("view constructor must be implemented")
    }
}

public protocol Coverable: HashValueIdentifiable {
    func asAnyFullScreenCover() -> AnyFullScreenCover
    func view() -> AnyView
}

extension Coverable {
    public func asAnyFullScreenCover() -> AnyFullScreenCover {
        AnyFullScreenCover(base: self)
    }

    public func view() -> AnyView {
        preconditionFailure("view constructor must be implemented")
    }
}

public struct AnyRoute: HashValueIdentifiable {
    let base: any Routable

    public static func == (lhs: AnyRoute, rhs: AnyRoute) -> Bool {
        lhs.base.hashValue == rhs.base.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(base.hashValue)
    }

    public func unwrap<T: Routable>(as type: T.Type) -> T? {
        base as? T
    }
}

public struct AnySheet: HashValueIdentifiable {
    let base: any Sheetable

    public static func == (lhs: AnySheet, rhs: AnySheet) -> Bool {
        lhs.base.hashValue == rhs.base.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(base.hashValue)
    }

    public func unwrap<T: Sheetable>(as type: T.Type) -> T? {
        base as? T
    }
}

public struct AnyFullScreenCover: HashValueIdentifiable {
    let base: any Coverable

    public static func == (lhs: AnyFullScreenCover, rhs: AnyFullScreenCover) -> Bool {
        lhs.base.hashValue == rhs.base.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(base.hashValue)
    }

    public func unwrap<T: Coverable>(as type: T.Type) -> T? {
        base as? T
    }
}

public struct AnyAlert: HashValueIdentifiable {
    public let title: String
    public let message: String?
    public let primaryButton: Alert.Button
    public let secondaryButton: Alert.Button?

    public init(
        title: String,
        message: String? = nil,
        primaryButton: Alert.Button,
        secondaryButton: Alert.Button? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }

    func asAlert() -> Alert {
        if let secondary = secondaryButton {
            return Alert(
                title: Text(title),
                message: message.map(Text.init),
                primaryButton: primaryButton,
                secondaryButton: secondary
            )
        } else {
            return Alert(
                title: Text(title),
                message: message.map(Text.init),
                dismissButton: primaryButton
            )
        }
    }

    public static func == (lhs: AnyAlert, rhs: AnyAlert) -> Bool {
        lhs.title == rhs.message &&
        lhs.message == rhs.message
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(message)
    }
}

public struct AnyConfirmationDialog: HashValueIdentifiable {
    public let title: String
    public let message: String?
    public let actions: [DialogAction]
    public let cancel: DialogAction?

    public struct DialogAction: Identifiable {
        public let id = UUID()
        public let title: String
        public let role: ButtonRole?
        public let action: () -> Void

        public init(title: String, role: ButtonRole? = nil, action: @escaping () -> Void = {}) {
            self.title = title
            self.role = role
            self.action = action
        }
    }

    public init(
        title: String,
        message: String? = nil,
        actions: [DialogAction],
        cancel: DialogAction? = nil
    ) {
        self.title = title
        self.message = message
        self.actions = actions
        self.cancel = cancel
    }


    public static func == (lhs: AnyConfirmationDialog, rhs: AnyConfirmationDialog) -> Bool {
        lhs.title == rhs.title &&
        lhs.message == rhs.message &&
        lhs.actions.map { $0.id } == rhs.actions.map { $0.id } &&
        lhs.actions.map { $0.title } == rhs.actions.map { $0.title } &&
        lhs.cancel?.id == rhs.cancel?.id &&
        lhs.cancel?.title == rhs.cancel?.title
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(message)
    }
}
