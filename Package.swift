// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReorderableSectionedList",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ReorderableSectionedList",
            targets: ["ReorderableSectionedList"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ReorderableSectionedList",
            dependencies: [
                "Introspect"
            ]),
        .testTarget(
            name: "ReorderableSectionedListTests",
            dependencies: ["ReorderableSectionedList"]),
    ]
)
