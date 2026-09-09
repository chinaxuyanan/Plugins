// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "LogKit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [.library(name: "LogKit", targets: ["LogKit"])],
    targets: [.target(name: "LogKit")]
)
