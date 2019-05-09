// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Storefront",
    platforms: [
        .macOS(.v10_13), .iOS(.v12)
    ],
    products: [
        .library(name: "Storefront", type: .static, targets: ["Storefront"])
    ],
    targets: [
        .target(name: "Storefront")
    ]
)
