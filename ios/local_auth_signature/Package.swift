// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "local_auth_signature",
    platforms: [
        .iOS("11.0")
    ],
    products: [
        .library(name: "local-auth-signature", targets: ["local_auth_signature"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/prongbang/SignatureBiometricSwift.git", from: "1.0.10")
    ],
    targets: [
        .target(
            name: "local_auth_signature",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "SignatureBiometricSwift", package: "SignatureBiometricSwift")
            ]
        )
    ]
)
