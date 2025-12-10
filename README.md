# Navigable

Declarative/Stateful navigation and presentation for SwiftUI — all from a single observable `NavigationState`.  
Push views onto the navigation stack, present sheets or full-screen covers over it, and show alerts or confirmation dialogs — all in one unified, testable system.

> Full API docs, guides, and samples live in the bundled **DocC**.

---

## Why Navigable?

- **One stateful source of truth** — drive routes, modal presentations, alerts, and confirmation dialogs from a single `Binding<NavigationState?>`.
- **Composable** — plug in your own builders for routes, sheets, full-screen covers, and alerts.
- **Deep-link ready** — construct the full view stack for a URL or programmatic route.
- **Opt-in ergonomics** — works with your existing views; no custom base classes.
- **Test-friendly** — assert against `NavigationState` mutations in unit tests.

---

## Requirements

- **iOS 17+** (uses `@Observable`).  
- **Swift 6** toolchain
- **SwiftUI**

---

## Installation (Swift Package Manager)

**Xcode:**  
- File → Add Package Dependencies… → paste the Git URL of this repo → Add.

**Or `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/<you>/Navigable.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["Navigable"]
    )
]
```
---

## Documentation

Navigable's detailed documentation is bundled in the project, you can view it locally by cloning the repo and building via Xcode `Product >> Build Documentation`
or view online [here](https://github.com/coreyd303/Navigable-SwiftUI/tree/main/Sources/Navigable/Navigation.docc)

---

## Quick Start

```swift
import SwiftUI
import Navigable

enum Routez: Routable {
    case route1
}

struct AppRoot: NavigableView {
    @State var navigationState: NavigationState?

    var body: some View {
        Text("Hello World")
            .applyNavigation(
                navigationState: $navigationState,
                isRootNavigator: true,
                destinationBuilder: { route in
                    guard let route = route.base as? Routez else {
                        preconditionFailure()
                    }

                    switch route {
                    case .route1:
                        return RouteView().eraseToAnyView()
                    }
                },
                sheetPresentationBuilder: { sheet in
                    guard let sheet = sheet.base as? Sheetz else {
                        preconditionFailure()
                    }

                    switch sheet {
                    case .sheet1:
                        return SheetView().eraseToAnyView()
                    }
                },
                fullScreenCoverPresentationBuilder: { cover in
                    ...presentCover
                }
            )
    }
}
```

### With this setup...

- Push / Pop a route

```swift
    push(MyRoute.someRoute)
    pop()
```

- Present a sheet or cover

```swift
    present(MySheet.someSheet)
    dismissPresentationOrDisplay()
```

- Show an alert or confirmation dialogue

```swift
    display(.init(...alertDetails))
    dismissPresentationOrDisplay()
```

---

## Contributing / Support

If you like the project, don't forget to put star 🌟!

Bug reports and PRs are welcome. Please:
	1.	Open an issue describing the change.
	2.	Include tests where practical.
	3.	Follow Swift API Design Guidelines.

---

## License

Navigable is available under the MIT license. See the LICENSE file for more info.
