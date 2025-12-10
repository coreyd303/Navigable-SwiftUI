# ⛵ Navigable

## Introduction

`Navigable` is a lightweight, protocol-driven architecture designed to make navigation in SwiftUI apps modular, scalable, and testable. It abstracts the mechanics of SwiftUI’s navigation stack, sheets, and full-screen covers into a declarative, composable system that is easy to adopt and extend across your application.
Inspired by the limitations of tightly coupled navigation logic, `Navigable` provides a clear contract for defining view destinations in a centralized way—moving navigation responsibility from views into view models or coordinators, where it can be reasoned about, tested, and reused more effectively.

## Purpose

The goal of `Navigable` is to **unify and simplify navigation** by introducing a consistent interface and separation of concerns. Instead of scattering `NavigationLink`, `.sheet`, or `.fullScreenCover` throughout your view hierarchy, `Navigable` provides a centralized model to:

- Define all possible navigation paths (`Route`, `Sheet`, `FullScreenCover`)
- Handle deep links or state restoration by mapping structured routes to destinations
- Decouple navigation logic from view rendering
- Promote reuse and consistency across the app

## Benefits

- ✅ **Declarative & Composable**: Navigation state lives in a `@Bindable` model and is driven through SwiftUI’s view hierarchy using a view modifier.
- ✅ **Stateful**: Prevent illegal navigation states by unifying `NavigationState` under one source of truth.
- ✅ **Deep Link Ready**: Routes can be constructed programmatically and matched to URLs or external triggers easily.
- ✅ **Centralized Navigation Logic**: All destination presentation logic is implemented in the conforming `Navigable` type, making the behavior explicit and testable.
- ✅ **No View Coupling**: Views no longer own or manage navigation directly—view models (or coordinators) do.
- ✅ **Flexible Presentation**: Supports `navigationDestination`, `.sheet`, and `.fullScreenCover` from the same unified model.
- ✅ **Macro-Compatible**: Designed to eventually support macro-based synthesis for reducing boilerplate.

## Implementation and Code Example

`Navigable` was designed to make implementation as easy and simple as possible. Subscribing to `Navigable` or `NavigableView` provides a synthesized super power for easy stateful navigation. It should be noted that the recommended way to implement `Navigable` is using a `Coordinator`, `ViewModel`, or other data 
provider object in conjunction with a view.

---

### 💡 This example demonstrates how to use `applyNavigation` with either `ViewModel` that conform to `Navigable`, or a view that conforms to `NavigableView`.
- To see this in action, check out the demo app in the [`Example/NavigableSampleApp`](https://github.com/coreyd303/Navigable-SwiftUI/tree/main/Example/NavigableSampleApp) folder!

**Run the Example:**
1. Clone this repository
2. Open `Example/NavigableSampleApp/NavigableSampleApp.xcodeproj`
3. Build and run to see Navigable in action!

In `Views` that leverage a `ViewModel`:  
- `@State var viewModel` drives the navigation state.
- `isRootNavigator: true` ensures the view manages its own `NavigationStack`.
    - **Prevents nested `NavigationStack`**, which can cause unexpected dismissal or broken back navigation.
    - Note: you can only have one root navigator in any workflow, having more than one will result in unexpected behaviors.
- `destinationBuilder` and other navigation methods are delegated to the `ViewModel`, encapsulating navigation logic.

---

### ✳️ A set of syntesized methods are provided to any object or view that conforms to `Navigable` or `NavigableView`. It is recommended that you use these methods instead of directly setting the value of `NavigationState`. These methods ensure that the navigation stack is unified and correctly managed as your navigation changes.
- `push(_ route: any Routable)` : push a route onto the stack 
- `push(_ routes: [any Routable])` : push multiple routes onto the stack
- `pop()` : pop the last route from the stack
- `popTo(index: Int)` : pop a specific route from the stack
- `popToRoot()` : pop to the bottom of the stack
- `swap(_ route: any Routable)` : replace the last route on the stack with a new route
- `present(_ fullScreenCover: any Coverable)` : present a full screen cover
- `present(_ sheet: any Sheetable)` : present a sheet
- `display(_ alert: AnyAlert)` : display an alert, this supports both `SwiftUI Alert` and `HatchAlert`
- `display(_ dialog: AnyConfirmationDialog)` : display a confirmation dialog
- `enqueue(navigation action: after delay:)` : 
    - When changing presentation or display on a `View`, ie: swapping from one Sheet to another, `SwiftUI` can find itself in a bit of a `nil` state conflict due to the async nature of `View`.
    - `enqueue` provides an elegant way to handle this, acheiving a smooth transion from one presentation or display to another.
    - `enqueue` can be use with any `NavigationState` but will result in a complete swap of the state, this is relevent when you have a preexisting stack. Take note: _enqueue will `nil` the state before replacing_.
- `dismissPresentationOrDisplay()` : dismiss a presentation or a display

---

### ✴️ A helper method is provided to facilitate unifying all `View` types into `AnyView`.
- `.eraseToAnyView()` is a synthesized method that is provided to easily and uniformly implement wrapping all custom `View` types into the type erased `AnyView` type. 

---

### ✨ Using `EmptyView()` as a fallback type is preferred.
- It is recommended that you use `EmptyView()` as your fallback type when implementing `Navigable`
    - This choice is intentional and preferred over other options such as throwing or optional returns to make implementation as seamless as possible
    - Using `EmptyView()` provides a very clear indication of issues that can be seen during UI testing or regressing, and clearly denotes develeoper errors as `EmptyView()` is an unexpected result of any navigation action 

---

### 💠 Syntesized methods are provided to manage all forms of navigation
- Navigable provides a set of synthesized methods to manage all possible navigation actions
- Failing default implementations are provided on both `Navigable` and `NavigableView`. This means you only need to implement what you need, and your code will fail fast if you try to perform a navigation type that you have not implemented support for.
    - `open func destination(for route: any Routable) -> AnyView` 
    - `open func sheetPresentation(for sheet: any Sheetable) -> AnyView`
    - `open func fullScreenCoverPresentation(for fullScreenCover: any Coverable) -> AnyView`
    - `open func alert(for alert: AnyAlert) -> AnyAlert`
    - `open func confirmationDialog(for dialog: AnyConfirmationDialog) -> AnyConfirmationDialog`

---

### 🟣 It is recommended to manage dismissal via call back
- While `SwiftUI`s `@Environment(\.dismiss)` can be used in conjunction with `Navigable` and `NavigableView` however it is preferrable to manage dismissal using a custom call back
    - This unifies all parts of the navigation life cycle, and ensures a fully stateful navigation experience
    - This also means that you can test dismissal when using `Navigable`!
        - Examples of this can be seen throughout the code sample

---
### 🟥 `applyNavigation` is the superpower!
- The `applyNavigation` func is where the magic of `Navigable` and `NavigableView` comes to life
    - This method passes the stateful `NavigationState` through to the `NavigationService` and drives all of your navigation needs
    - In order to simplify implementation, synthesized methods are provided on both `Navigable` and `NavigableView`. These builder methods do all the heavy lifting for you, and are available on both `Navigable` and `NavigableView`
        - destinationBuilder
        - sheetPresentationBuilder
        - fullScreenCoverPresentationBuilder

---

### 🔆 Atomic implementations of `Navigable` objects are reuseable
- Keep in mind, that you need to consider preserved state!
    - Because `Navigable` applies only to reference types, any existing instance passed in to a child `View` etc. will maintain reference semantics.

---

```swift
// MARK: Root View

struct BaseView: View {
    @State var viewModel = BaseViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Button("Push Route") {
                viewModel.push(Routez.route1) // ✳️ a set of syntesized methods are provided to any object or view that conforms to `Navigable` or `NavigableView`
            }
        }
        .buttonStyle(.primaryV2)
        .applyNavigation( // 🟥 `applyNavigation` is the superpower!
            navigationState: $viewModel.navigationState,
            isRootNavigator: true,
            destinationBuilder: viewModel.destinationBuilder
        )
    }
}

#Preview {
    BaseView()
}
```

> #### 💡 Each `Navigable` type is defined using an enum. In this case, we are defining routes tied to the root `NavigationStack`.

```swift
enum Routez: Routable {
    case route1
}

@Observable
final class BaseViewModel: Navigable {
    override func destination(for route: any Routable) -> AnyView { // 💠 Syntesized methods are provided to manage all forms of navigation
        guard let route = route as? Routez else {
            return EmptyView().eraseToAnyView() 
            // ✴️ A helper method is provided to facilitate unifying all View types into AnyView. 
            // ✨ Using EmptyView as a fallback type is preferred.
        }

        switch route {
        case .route1:
            return RouteView {
                self.pop() 
                // ✳️ a set of syntesized methods are provided to any object or view that conforms to `Navigable` or `NavigableView`
                // 🟣 It is recommended to manage dismissal via call back
            }
            .eraseToAnyView() // ✴️ A helper method is provided to facilitate unifying all View types into AnyView.
        }
    }
}

// MARK: - Route View

struct RouteView: View {
    @State var viewModel = RouteViewModel()
    let dismissView: () -> Void // 🟣 It is recommended to manage dismissal via call back

    var body: some View {
        VStack(spacing: 20) {
            Text("Route View")

            Button("Present Sheet") {
                viewModel.present(Sheetz.sheet1) // ✳️ a set of syntesized methods are provided to any object or view that conforms to `Navigable` or `NavigableView`
            }

            Button("Dismiss Me") {
                dismissView() // 🟣 It is recommended to manage dismissal via call back
            }
        }
        .buttonStyle(.primaryV2)
        .applyNavigation( // 🟥 `applyNavigation` is the superpower!
            navigationState: $viewModel.navigationState,
            isRootNavigator: false,
            sheetPresentationBuilder: viewModel.sheetPresentationBuilder
        )
    }
}
```

> #### 💡 Each `Navigable` type is defined using an enum. In this case, we are defining sheets tied to the root `NavigationStack`.

```swift
enum Sheetz: Sheetable {
    case sheet1
    case sheet2
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
                dismissView: {
                    // ✳️ a set of syntesized methods are provided to any object or view that conforms to `Navigable` or `NavigableView`
                    self.enqueue { 
                        self.present(Sheetz.sheet2)
                    }
                }
            )
            .eraseToAnyView()
        case .sheet2:
            return AnotherSheetView(
                dismissAction: {
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

// MARK: Sheet View

struct SheetView: View {
    @State var viewModel = RouteViewModel() // 🔆 Atomic implementations of `Navigable` objects are reuseable
    let dismissView: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Sheet View")

            Button("Present another sheet") {
                viewModel.present(Sheetz.sheet2) // ✳️ a set of syntesized methods are provided to any object or view that conforms to `Navigable` or `NavigableView`
            }

            Button("Dismiss Me") {
                dismissView()
            }
        }
        .buttonStyle(.primaryV2)
        .applyNavigation( // 🟥 `applyNavigation` is the superpower!
            navigationState: $viewModel.navigationState,
            isRootNavigator: false,
            sheetPresentationBuilder: viewModel.sheetPresentationBuilder
        )
    }
}
```

>#### In this case, you will see that the `View` implements `NavigableView`. This has tradeoffs, but with correct consideration can be used appropriatly.
> This view only requires a confirmation dialog presentation, the business logic behind it is managed through a custom callback.

```swift
// MARK: Another Sheet View

struct AnotherSheetView: NavigableView {
    @State var navigationState: NavigationState? // 📌 `NavigableView` being a protocol does require that we maintain our own stateful reference
    let dismissView: () -> Void
    let confirmationAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Another Sheet View")

            Button("Confirm?") {
                display( // ✳️ a set of syntesized methods are provided to any object or view that conforms to `Navigable` or `NavigableView`
                    confirmationDialog,
                    using: $navigationState
                ) 
            }
        }
        .buttonStyle(.primaryV2)
        .applyNavigation( // 📌 in this case we don't need to leverage any builders
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
                    title: "Yes!",
                    action: {
                        confirmationAction()
                    }
                ),
                AnyConfirmationDialog.DialogAction(
                    title: "No!",
                    role: .cancel,
                    action: {
                        display(alert, using: $navigationState) // 📌 because `NavigationState` is stateful, we don't have to fear illegal states
                    }
                )
            ]
        )
    }

    private var alert: AnyAlert {
        AnyAlert(
            style: .system(
                title: "Boo Hoo",
                message: "That's too bad!",
                primaryButton: .cancel(),
                secondaryButton: nil
            )
        )
    }
}
```
