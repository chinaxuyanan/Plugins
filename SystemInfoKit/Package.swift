// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SystemInfoKit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [.library(name: "SystemInfoKit", targets: ["SystemInfoKit"])],
    targets: [
        .target(name: "SystemInfoKit"),
        .testTarget(name: "SystemInfoKitTests", dependencies: ["SystemInfoKit"])
    ]
)
