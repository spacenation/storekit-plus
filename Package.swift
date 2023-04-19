// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Storefront",
    platforms: [
        .iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9)
    ],
    products: [
        .library(name: "Storefront", targets: ["Storefront"])
    ],
    targets: [
        .target(name: "Storefront"),
        .testTarget(name: "StorefrontTests", dependencies: ["Storefront"])
    ]
)
