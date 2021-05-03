// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "StoreKitExtensions",
    platforms: [
        .iOS(.v14), .macOS(.v11), .tvOS(.v14)
    ],
    products: [
        .library(name: "StoreKitExtensions", type: .static, targets: ["StoreKitExtensions"])
    ],
    targets: [
        .target(name: "StoreKitExtensions"),
        .testTarget(name: "StoreKitExtensionsTests", dependencies: ["StoreKitExtensions"])
    ]
)
