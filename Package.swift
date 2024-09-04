// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "tradedoubler-ios-sdk",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(name: "tradedoubler-ios-sdk", targets: ["TradeDoublerSDK"])
    ],
    targets: [
        .target(
            name: "TradeDoublerSDK",
            path: "TradeDoublerDemo/TradeDoublerSDK"
        )
    ]
)