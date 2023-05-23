// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "StoreKitPlus",
    platforms: [
        .iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8)
    ],
    products: [
        .library(name: "StoreKitPlus", targets: ["StoreKitPlus"])
    ],
    targets: [
        .target(name: "StoreKitPlus"),
        .testTarget(name: "StoreKitPlusTests", dependencies: ["StoreKitPlus"])
    ]
)
