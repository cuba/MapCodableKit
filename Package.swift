// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapCodable",
    products: [
        .library(name: "MapCodable", targets: ["MapCodable"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "MapCodable", path: "Sources"),
        .testTarget(name: "MapCodableTests", dependencies: ["MapCodable"], path: "Tests"),
    ]
)
