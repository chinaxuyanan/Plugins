# Plugins

[![CI](https://github.com/chinaxuyanan/Plugins/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/chinaxuyanan/Plugins/actions/workflows/ci.yml)

一组自用的 Swift / SwiftUI 工具库，集中放在同一个仓库里维护。

## 仓库结构

```
Plugins/
├── SwiftUIProKit/      # SwiftUI 控件属性封装 + 复合组件
├── LogKit/             # 日志库（级别 / 分类 / 过滤 / 文件轮转 / 导出）
├── SystemInfoKit/      # 系统信息检测（CPU / 内存 / 磁盘 / 电池 / 网络…）
├── KitsDemo/           # 三库的演示工程（macOS SwiftUI 可执行）
├── CodeSnippets/       # Xcode 代码片段（.codesnippet）
└── .github/workflows/  # CI：构建 + 单元测试 + iOS 编译检查
```

三个库**各自是独立的 Swift Package**，各带自己的 `Package.swift`、README、测试与版本号，只是放在同一个仓库里。每个库的用法、API 清单和版本变更记录见各自的 README：

| 库 | 说明 | 版本 |
| --- | --- | --- |
| [SwiftUIProKit](SwiftUIProKit/README.md) | SwiftUI 控件属性太多、不知道用哪个？这里把常用控件与属性收成一组封装和复合组件 | 1.7.0 |
| [LogKit](LogKit/README.md) | 分级 / 分类 / 过滤 / 采样 / 文件轮转 / CSV·JSON 导出 | 1.4.0 |
| [SystemInfoKit](SystemInfoKit/README.md) | 设备、CPU、内存、磁盘、电池、网络等系统信息检测 | 1.4.0 |

## 怎么用

### 方式一：本地路径依赖（推荐，也是 KitsDemo 用的方式）

把本仓库 clone 到本地，然后在你的工程里按路径依赖要用到的包：

```swift
dependencies: [
    .package(path: "../Plugins/SwiftUIProKit"),
    .package(path: "../Plugins/LogKit"),
    .package(path: "../Plugins/SystemInfoKit"),
],
targets: [
    .target(
        name: "你的模块",
        dependencies: [
            .product(name: "SwiftUIProKit", package: "SwiftUIProKit"),
            .product(name: "LogKit", package: "LogKit"),
            .product(name: "SystemInfoKit", package: "SystemInfoKit"),
        ]
    ),
]
```

不用哪个就不写哪个。

### 方式二：远端依赖（有前提）

**SwiftPM 目前无法从远端仓库的子目录里解析包**——它要求 `Package.swift` 位于仓库根目录，而本仓库根目录下是三个并排的包。这属于 SwiftPM 自身的限制，官方两条 feature request 都还开着：允许 `Package.swift` 不在根目录（[swift-package-manager#5768](https://github.com/swiftlang/swift-package-manager/issues/5768)）、支持带前缀的版本 tag（[swift-package-manager#5780](https://github.com/swiftlang/swift-package-manager/issues/5780)）。

所以要用远端的话，只能 clone 下来走方式一的本地路径。**如果以后想让别人（或你自己的其它机器）直接按版本依赖**，最小的改动是在仓库根目录加一个 `Package.swift`，把三个库收成三个 product——那样三个包就变成一个包、共用一套版本号，但外部就能写 `.package(url: ".../Plugins", from: "1.7.0")` 了。需要的时候说一声。

## 版本与 tag

三个库版本独立演进，所以 tag 带库名前缀：

```
SwiftUIProKit-1.7.0
LogKit-1.4.0
SystemInfoKit-1.4.0
```

（仓库级别不能再用裸的版本号，三个库会撞名。）各库当前版本号也能在代码里读到，例如 `LogKit.version`。

> **版本号规则**：自 2026-09 起改为「满十进位式」——次版本满 10 就进位到主版本，`0.13.0` 的下一版写作 `1.4.0`（而不是 `0.14.0`）。此前已发布的 `0.x` tag 原样保留。

## 开发

改完代码，在对应目录里跑测试：

```bash
swift test --package-path SwiftUIProKit
swift test --package-path LogKit
swift test --package-path SystemInfoKit
swift build --package-path KitsDemo
```

推到 GitHub 后，`.github/workflows/ci.yml` 会在这三个库 + KitsDemo 上跑一遍构建与测试，并单独编一遍 iOS 目标（用来抓「只写了 `#if os(macOS)`、漏了 iOS」这类平台专有符号泄漏）。提交与推送步骤见 [推送GitHub步骤.md](推送GitHub步骤.md)。
