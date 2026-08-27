// swift-tools-version:6.2

import PackageDescription

let iOSPlatforms: [Platform] = [.iOS, .visionOS, .macCatalyst]
let macOSPlatforms: [Platform] = [.macOS]

// Note: `-warnings-as-errors` is deliberately not enabled here. Per
// https://forums.swift.org/t/warnings-as-errors-in-sub-packages/70810, having that flag in a
// sub-package conflicts with the automatic "-suppress-warnings" flag added by Xcode. It is also passed
// via `.unsafeFlags`, which would make this package ineligible as a dependency of other packages.
let swiftSettings: [SwiftSetting] = [
    .defaultIsolation(MainActor.self)
]

// Test targets deliberately omit `.defaultIsolation(MainActor.self)`.
let testSwiftSettings: [SwiftSetting] = []

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
        path: "Tests/FluentUI_iOS_Tests",
        swiftSettings: testSwiftSettings
    ),
    .testTarget(
        name: "FluentUI_macOS_Tests",
        dependencies: [
            .target(name: "FluentUI_macos", condition: .when(platforms: macOSPlatforms))
        ],
        path: "Tests/FluentUI_macOS_Tests",
        swiftSettings: testSwiftSettings
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
