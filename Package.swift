// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SwiftUIProKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "SwiftUIProKit", targets: ["SwiftUIProKit"])
    ],
    targets: [
        .target(name: "SwiftUIProKit"),
        .testTarget(name: "SwiftUIProKitTests", dependencies: ["SwiftUIProKit"])
    ]
)
