// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Storefront",
    platforms: [
        .iOS(.v14), .macOS(.v11), .tvOS(.v14)
    ],
    products: [
        .library(name: "Storefront", type: .static, targets: ["Storefront"])
    ],
    targets: [
        .target(name: "Storefront"),
        .testTarget(name: "StorefrontTests", dependencies: ["Storefront"])
    ]
)
