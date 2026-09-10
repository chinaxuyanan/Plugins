import Foundation

/// 一个已挂载的存储卷
///
/// 由 `SystemInfoKit.mountedVolumes` 返回的列表元素（也可用 `removableVolumes` 只看可移除的卷）。
/// 容量单位均为字节，另附人类可读的格式化串，便于直接贴到界面上。
///
/// - Example:
///   ```swift
///   for 卷 in SystemInfoKit.mountedVolumes {
///       print("\(卷.name)：\(卷.usedDescription) / \(卷.totalDescription)（已用 \(卷.usedPercentText)）")
///   }
///   ```
public struct MountedVolume: Identifiable, Hashable {

    /// 卷名（如 `Macintosh HD` / `外接硬盘`）
    public let name: String
    /// 挂载点路径
    public let url: URL
    /// 总容量（字节）
    public let totalBytes: Int64
    /// 可用容量（字节）
    public let freeBytes: Int64
    /// 是否可移除（U 盘 / 存储卡 / 外接盘）
    public let isRemovable: Bool
    /// 是否内置磁盘（`false` 多为外接设备 / 磁盘映像）
    public let isInternal: Bool

    /// 唯一标识（挂载点路径）
    public var id: String { url.path }

    /// - Parameters:
    ///   - name: 卷名
    ///   - url: 挂载点路径
    ///   - totalBytes: 总容量（字节）
    ///   - freeBytes: 可用容量（字节）
    ///   - isRemovable: 是否可移除
    ///   - isInternal: 是否内置磁盘
    public init(name: String,
                url: URL,
                totalBytes: Int64,
                freeBytes: Int64,
                isRemovable: Bool,
                isInternal: Bool) {
        self.name = name
        self.url = url
        self.totalBytes = totalBytes
        self.freeBytes = freeBytes
        self.isRemovable = isRemovable
        self.isInternal = isInternal
    }

    /// 已用容量（字节；总容量小于可用容量时按 `0` 计）
    public var usedBytes: Int64 {
        max(0, totalBytes - freeBytes)
    }

    /// 已用容量占比（`0.0` ~ `1.0`；总容量为 `0` 时返回 `0`）
    public var usedRatio: Double {
        totalBytes > 0 ? Double(usedBytes) / Double(totalBytes) : 0
    }

    /// 已用容量占比（人类可读，形如 `62.5%`）
    public var usedPercentText: String {
        String(format: "%.1f%%", usedRatio * 100)
    }

    /// 总容量（人类可读，形如 `1 TB`）
    public var totalDescription: String {
        ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }

    /// 已用容量（人类可读，形如 `620 GB`）
    public var usedDescription: String {
        ByteCountFormatter.string(fromByteCount: usedBytes, countStyle: .file)
    }

    /// 可用容量（人类可读，形如 `380 GB`）
    public var freeDescription: String {
        ByteCountFormatter.string(fromByteCount: freeBytes, countStyle: .file)
    }

    /// 卷类型中文名（「内置磁盘」/「可移除设备」/「外接磁盘」）
    public var kindName: String {
        if isRemovable { return "可移除设备" }
        return isInternal ? "内置磁盘" : "外接磁盘"
    }
}

// MARK: 中文命名别名

/// 中文名：存储卷（等同 `MountedVolume`）
public typealias 存储卷 = MountedVolume

public extension MountedVolume {

    /// 创建存储卷（中文参数）
    /// - Parameters:
    ///   - 名称: 卷名
    ///   - 路径: 挂载点路径
    ///   - 总容量: 总容量（字节）
    ///   - 可用容量: 可用容量（字节）
    ///   - 是否可移除: 是否可移除（U 盘 / 存储卡 / 外接盘）
    ///   - 是否内置: 是否内置磁盘
    init(名称: String,
         路径: URL,
         总容量: Int64,
         可用容量: Int64,
         是否可移除: Bool,
         是否内置: Bool) {
        self.init(name: 名称,
                  url: 路径,
                  totalBytes: 总容量,
                  freeBytes: 可用容量,
                  isRemovable: 是否可移除,
                  isInternal: 是否内置)
    }

    /// 卷名（等同 `name`）
    var 名称: String { name }

    /// 挂载点路径（等同 `url`）
    var 路径: URL { url }

    /// 总容量字节（等同 `totalBytes`）
    var 总容量: Int64 { totalBytes }

    /// 可用容量字节（等同 `freeBytes`）
    var 可用容量: Int64 { freeBytes }

    /// 是否可移除（等同 `isRemovable`）
    var 是否可移除: Bool { isRemovable }

    /// 是否内置磁盘（等同 `isInternal`）
    var 是否内置: Bool { isInternal }

    /// 已用容量字节（等同 `usedBytes`）
    var 已用字节数: Int64 { usedBytes }

    /// 已用容量占比（等同 `usedRatio`）
    var 已用占比: Double { usedRatio }

    /// 已用容量占比文本（等同 `usedPercentText`）
    var 已用占比文本: String { usedPercentText }

    /// 总容量文本（等同 `totalDescription`）
    var 总容量文本: String { totalDescription }

    /// 已用容量文本（等同 `usedDescription`）
    var 已用文本: String { usedDescription }

    /// 可用容量文本（等同 `freeDescription`）
    var 可用文本: String { freeDescription }

    /// 卷类型中文名（等同 `kindName`）
    var 类型名: String { kindName }
}
