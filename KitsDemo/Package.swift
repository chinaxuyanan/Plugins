// swift-tools-version:5.7
import PackageDescription

// KitsDemo —— 三库本地演示工程（macOS SwiftUI 可执行）
// 以「本地路径依赖」直接引用同目录下的三个工具库，无需发布 / 拉取远程仓库。
let package = Package(
    name: "KitsDemo",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(path: "../SwiftUIProKit"),
        .package(path: "../LogKit"),
        .package(path: "../SystemInfoKit"),
    ],
    targets: [
        .executableTarget(
            name: "KitsDemo",
            dependencies: [
                .product(name: "SwiftUIProKit", package: "SwiftUIProKit"),
                .product(name: "LogKit", package: "LogKit"),
                .product(name: "SystemInfoKit", package: "SystemInfoKit"),
            ]
        )
    ]
)
