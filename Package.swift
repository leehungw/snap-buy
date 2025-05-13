// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "snap-buy",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "snap-buy",
            targets: ["snap-buy"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kitura/Swift-SMTP", .upToNextMinor(from: "5.1.0")),    // add the dependency
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "snap-buy",
            dependencies: ["SwiftSMTP"]),
        .testTarget(
            name: "snap-buyTests",
            dependencies: ["snap-buy"]
        ),
    ]
)
