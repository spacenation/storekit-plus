// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "StoreKitExtensions",
    platforms: [
         .iOS(.v13), .macOS(.v10_15)
    ],
    products: [
        .library(name: "StoreKitExtensions", type: .static, targets: ["StoreKitExtensions"])
    ],
    targets: [
        .target(name: "StoreKitExtensions"),
        .testTarget(name: "StoreKitExtensionsTests", dependencies: ["StoreKitExtensions"])
    ]
)
