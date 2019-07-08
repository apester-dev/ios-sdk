// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ApesterKit",
    products: [
        .library(
            name: "ApesterKit",
            targets: ["ApesterKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ApesterKit",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "ApesterKitTests",
            dependencies: ["ApesterKit"]),
    ]
)
