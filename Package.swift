// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CleanMac",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "CleanMac", targets: ["CleanMac"])
    ],
    targets: [
        .executableTarget(
            name: "CleanMac",
            path: "CleanMac",
            exclude: [
                "Resources/Info.plist"
            ],
            resources: [
                .copy("Resources/CleanMac.entitlements")
            ],
            swiftSettings: [
                .unsafeFlags(["-framework", "Carbon"])
            ],
            linkerSettings: [
                .linkedFramework("Carbon"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("AppKit"),
                .linkedFramework("ServiceManagement"),
                .linkedFramework("UserNotifications")
            ]
        )
    ]
)
