// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Storefront",
    platforms: [
        .iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8)
    ],
    products: [
        .library(name: "Storefront", targets: ["Storefront"])
    ],
    targets: [
        .target(name: "Storefront"),
        .testTarget(name: "StorefrontTests", dependencies: ["Storefront"])
    ]
)
