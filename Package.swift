// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Navigable",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Navigable",
            targets: ["Navigable"]
        ),
    ],
    targets: [
        // Internal helpers (NOT exposed as a product)
        .target(
            name: "NavigableSupport",
            path: "Sources/Support",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "Navigable",
            dependencies: [
                .target(name: "NavigableSupport")
            ],
            path: "Sources/Navigable",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "NavigableTests",
            dependencies: ["Navigable"],
            path: "Tests/NavigableTests",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
