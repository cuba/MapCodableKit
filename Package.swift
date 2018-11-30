// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapCodable",
    products: [
        .library(name: "MapCodable", targets: ["MapCodable"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "MapCodable"),
        .testTarget(name: "MapCodableTests", dependencies: ["MapCodable"]),
    ]
)
