// swift-tools-version:6.2

import PackageDescription

let iOSPlatforms: [Platform] = [.iOS, .visionOS, .macCatalyst]
let macOSPlatforms: [Platform] = [.macOS]

let swiftSettings: [SwiftSetting] = [
    .defaultIsolation(MainActor.self)
]

let targets: [Target] = [
    .target(
        name: "FluentUI",
        dependencies: [
            .targetItem(name: "FluentUI_ios", condition: .when(platforms: iOSPlatforms)),
            .targetItem(name: "FluentUI_macos", condition: .when(platforms: macOSPlatforms))
        ],
        path: "Sources/FluentUI",
        swiftSettings: swiftSettings
    ),
    .target(
        name: "FluentUI_ios",
        dependencies: [
            .target(name: "FluentUI_common")
        ],
        path: "Sources/FluentUI_iOS",
        resources: [
            .copy("Resources/Version.plist")
        ],
        swiftSettings: swiftSettings
    ),
    .target(
        name: "FluentUI_macos",
        dependencies: [
            .target(name: "FluentUI_common")
        ],
        path: "Sources/FluentUI_macOS",
        swiftSettings: swiftSettings
    ),
    .target(
        name: "FluentUI_common",
        path: "Sources/FluentUI_common",
        swiftSettings: swiftSettings
    )
]
let testTargets: [Target] = [
    .testTarget(
        name: "FluentUI_iOS_Tests",
        dependencies: [
            .target(name: "FluentUI_ios", condition: .when(platforms: iOSPlatforms)),
        ],
        path: "Tests/FluentUI_iOS_Tests"
    ),
    .testTarget(
        name: "FluentUI_macOS_Tests",
        dependencies: [
            .target(name: "FluentUI_macos", condition: .when(platforms: macOSPlatforms))
        ],
        path: "Tests/FluentUI_macOS_Tests"
    )
]

let package = Package(
    name: "FluentUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "FluentUI",
            type: .static,
            targets: [
                "FluentUI"
            ]
        )
    ],
    targets: targets + testTargets,
    swiftLanguageModes: [.v6]
)
