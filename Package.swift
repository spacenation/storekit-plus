// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Storefront",
    platforms: [
         .iOS(.v13), .macOS(.v10_15)
    ],
    products: [
        .library(name: "Storefront", type: .static, targets: ["Storefront"])
    ],
    targets: [
        .target(name: "Storefront")
    ]
)
