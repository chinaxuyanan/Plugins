import Foundation

/// 一个已安装的应用（macOS）
///
/// 由 `SystemInfoKit.installedApplications` 扫描 `/Applications` 与 `/System/Applications`
/// 下的 `.app` 包得到，名称 / 标识符 / 版本号均读自各自包内的 `Info.plist`。
///
/// 只扫两层目录的**顶层**（不深入每个 `.app` 内部），所以不会把 App 里嵌的辅助程序也算进来。
///
/// - Example:
///   ```swift
///   for 应用 in SystemInfoKit.installedApplications {
///       print("\(应用.name) \(应用.versionText) — \(应用.bundleIdentifier ?? "无标识符")")
///   }
///   ```
public struct InstalledApplication: Identifiable, Hashable {

    /// 应用名（优先 `CFBundleDisplayName`，其次 `CFBundleName`，都没有时用去扩展名的文件名）
    public let name: String
    /// 包标识符（如 `com.apple.Safari`；读不到为 `nil`）
    public let bundleIdentifier: String?
    /// 版本号（`CFBundleShortVersionString`；读不到为 `nil`）
    public let version: String?
    /// 应用包路径（`.app` 的 URL）
    public let url: URL

    /// 唯一标识（应用包路径）
    public var id: String { url.path }

    /// 创建一条已安装应用记录
    /// - Parameters:
    ///   - name: 应用名
    ///   - bundleIdentifier: 包标识符
    ///   - version: 版本号
    ///   - url: 应用包路径
    public init(name: String, bundleIdentifier: String?, version: String?, url: URL) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.version = version
        self.url = url
    }

    /// 版本号文本（读不到或为空串时返回「未知」）
    public var versionText: String {
        guard let version, !version.isEmpty else { return "未知" }
        return version
    }

    /// 包标识符文本（读不到或为空串时返回「未知」）
    public var bundleIdentifierText: String {
        guard let bundleIdentifier, !bundleIdentifier.isEmpty else { return "未知" }
        return bundleIdentifier
    }

    /// 应用包路径文本
    public var path: String { url.path }
}

// MARK: 中文命名别名

/// 中文名：已安装应用（等同 `InstalledApplication`）
public typealias 已安装应用 = InstalledApplication

public extension InstalledApplication {

    /// 创建一条已安装应用记录（中文参数）
    /// - Parameters:
    ///   - 名称: 应用名
    ///   - 标识符: 包标识符
    ///   - 版本: 版本号
    ///   - 路径: 应用包路径
    init(名称: String, 标识符: String?, 版本: String?, 路径: URL) {
        self.init(name: 名称, bundleIdentifier: 标识符, version: 版本, url: 路径)
    }

    /// 应用名（等同 `name`）
    var 名称: String { name }
    /// 包标识符（等同 `bundleIdentifier`）
    var 标识符: String? { bundleIdentifier }
    /// 版本号（等同 `version`）
    var 版本: String? { version }
    /// 应用包路径（等同 `url`）
    var 路径: URL { url }
    /// 版本号文本（等同 `versionText`）
    var 版本文本: String { versionText }
    /// 包标识符文本（等同 `bundleIdentifierText`）
    var 标识符文本: String { bundleIdentifierText }
}
