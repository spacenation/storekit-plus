// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Storefront",
    products: [
        .library(name: "Storefront", targets: ["Storefront"])
    ],
    targets: [
        .target(name: "Storefront"),
        .testTarget(name: "StorefrontTests", dependencies: ["Storefront"])
    ]
)
