// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapCodableKit",
    products: [
        .library(name: "MapCodableKit", targets: ["MapCodableKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "MapCodableKit", path: "Sources"),
        .testTarget(name: "MapCodableKitTests", dependencies: ["MapCodableKit"], path: "Tests"),
    ]
)
