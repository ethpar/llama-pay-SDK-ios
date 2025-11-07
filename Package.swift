// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PosSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "PosSDK",
            targets: ["PosSDK"]
        ),
    ],
    targets: [
        .target(
            name: "PosSDK",
            dependencies: []
        ),
        .testTarget(
            name: "PosSDKTests",
            dependencies: ["PosSDK"]
        ),
    ]
)
