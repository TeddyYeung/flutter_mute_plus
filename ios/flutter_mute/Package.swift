// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_mute",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "flutter-mute", targets: ["flutter_mute"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_mute",
            dependencies: [],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .headerSearchPath("include/flutter_mute")
            ]
        )
    ]
)
