import Foundation

/// 内存占用明细
///
/// 把「已用 / 可用」再往下拆一层，看清内存都被什么占着。数据来自 mach `host_statistics64`
/// （`vm_statistics64`），口径与「活动监视器」接近但不完全等同（系统还会把一部分页算作缓存）。
///
/// 各项含义：
/// - `freeBytes`：完全空闲、随时可用
/// - `activeBytes`：最近被访问、正在使用
/// - `inactiveBytes`：暂时没被访问，但内容还留着（可被回收）
/// - `wiredBytes`：被内核锁定、不可换出（不能回收，也叫「联动内存」）
/// - `compressedBytes`：被内存压缩器压过的页（macOS 的「已压缩内存」）
/// - `purgeableBytes` / `speculativeBytes`：可随时丢弃 / 预读的页
///
/// **可用内存 = 空闲 + 非活跃 + 可丢弃 + 预读**，与 `SystemInfoKit.availableMemoryBytes` 同口径；
/// 已用 = 总容量 − 可用。
///
/// - Example:
///   ```swift
///   if let 明细 = SystemInfoKit.memoryBreakdown {
///       print(明细.text)
///       // 内存 16 GB · 已用 9.8 GB（61.3%）· 可用 6.2 GB
///       // 活跃 4.1 GB · 非活跃 3.0 GB · 联动 2.2 GB · 压缩 1.5 GB
///
///       print(明细.wiredDescription)      // 联动内存，不可回收
///   }
///   ```
public struct MemoryBreakdown: Hashable {

    /// 物理内存总容量（字节）
    public let totalBytes: UInt64
    /// 完全空闲的内存（字节）
    public let freeBytes: UInt64
    /// 活跃内存（字节）
    public let activeBytes: UInt64
    /// 非活跃内存（字节）
    public let inactiveBytes: UInt64
    /// 联动内存（字节，被内核锁定不可回收）
    public let wiredBytes: UInt64
    /// 已压缩内存（字节）
    public let compressedBytes: UInt64
    /// 可随时丢弃的内存（字节）
    public let purgeableBytes: UInt64
    /// 预读（推测性）内存（字节）
    public let speculativeBytes: UInt64

    /// 创建内存明细
    /// - Parameters:
    ///   - totalBytes: 物理内存总容量（字节）
    ///   - freeBytes: 完全空闲的内存（字节）
    ///   - activeBytes: 活跃内存（字节）
    ///   - inactiveBytes: 非活跃内存（字节）
    ///   - wiredBytes: 联动内存（字节）
    ///   - compressedBytes: 已压缩内存（字节）
    ///   - purgeableBytes: 可随时丢弃的内存（字节）
    ///   - speculativeBytes: 预读内存（字节）
    public init(totalBytes: UInt64,
                freeBytes: UInt64,
                activeBytes: UInt64,
                inactiveBytes: UInt64,
                wiredBytes: UInt64,
                compressedBytes: UInt64,
                purgeableBytes: UInt64,
                speculativeBytes: UInt64) {
        self.totalBytes = totalBytes
        self.freeBytes = freeBytes
        self.activeBytes = activeBytes
        self.inactiveBytes = inactiveBytes
        self.wiredBytes = wiredBytes
        self.compressedBytes = compressedBytes
        self.purgeableBytes = purgeableBytes
        self.speculativeBytes = speculativeBytes
    }

    /// 可用内存（字节）= 空闲 + 非活跃 + 可丢弃 + 预读
    public var availableBytes: UInt64 {
        freeBytes &+ inactiveBytes &+ purgeableBytes &+ speculativeBytes
    }

    /// 已用内存（字节）= 总容量 − 可用（总容量小于可用时按 `0` 计）
    public var usedBytes: UInt64 {
        totalBytes > availableBytes ? totalBytes - availableBytes : 0
    }

    /// 内存使用率（`0.0` ~ `1.0`；总容量为 `0` 时返回 `0`）
    public var usedPercent: Double {
        totalBytes > 0 ? Double(usedBytes) / Double(totalBytes) : 0
    }

    /// 内存使用率文本（形如 `61.3%`）
    public var usedPercentText: String {
        String(format: "%.1f%%", usedPercent * 100)
    }

    /// 总容量（人类可读，形如 `16 GB`）
    public var totalDescription: String { Self.description(of: totalBytes) }
    /// 已用内存（人类可读，形如 `9.8 GB`）
    public var usedDescription: String { Self.description(of: usedBytes) }
    /// 可用内存（人类可读，形如 `6.2 GB`）
    public var availableDescription: String { Self.description(of: availableBytes) }
    /// 空闲内存（人类可读）
    public var freeDescription: String { Self.description(of: freeBytes) }
    /// 活跃内存（人类可读）
    public var activeDescription: String { Self.description(of: activeBytes) }
    /// 非活跃内存（人类可读）
    public var inactiveDescription: String { Self.description(of: inactiveBytes) }
    /// 联动内存（人类可读）
    public var wiredDescription: String { Self.description(of: wiredBytes) }
    /// 已压缩内存（人类可读）
    public var compressedDescription: String { Self.description(of: compressedBytes) }

    /// 中文多行摘要（第一行总量，第二行各分项）
    public var text: String {
        var lines: [String] = []
        lines.append("内存 \(totalDescription) · 已用 \(usedDescription)（\(usedPercentText)）· 可用 \(availableDescription)")
        lines.append("活跃 \(activeDescription) · 非活跃 \(inactiveDescription) · 联动 \(wiredDescription) · 压缩 \(compressedDescription)")
        return lines.joined(separator: "\n")
    }

    /// 内部：字节数转人类可读文本（按内存口径 1024 进制）
    private static func description(of bytes: UInt64) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(clamping: bytes), countStyle: .memory)
    }
}

// MARK: 中文命名别名

/// 中文名：内存明细（等同 `MemoryBreakdown`）
public typealias 内存明细 = MemoryBreakdown

public extension MemoryBreakdown {

    /// 创建内存明细（中文参数）
    /// - Parameters:
    ///   - 总容量: 物理内存总容量（字节）
    ///   - 空闲: 完全空闲的内存（字节）
    ///   - 活跃: 活跃内存（字节）
    ///   - 非活跃: 非活跃内存（字节）
    ///   - 联动: 联动内存（字节）
    ///   - 压缩: 已压缩内存（字节）
    ///   - 可丢弃: 可随时丢弃的内存（字节）
    ///   - 预读: 预读内存（字节）
    init(总容量: UInt64,
         空闲: UInt64,
         活跃: UInt64,
         非活跃: UInt64,
         联动: UInt64,
         压缩: UInt64,
         可丢弃: UInt64,
         预读: UInt64) {
        self.init(totalBytes: 总容量,
                  freeBytes: 空闲,
                  activeBytes: 活跃,
                  inactiveBytes: 非活跃,
                  wiredBytes: 联动,
                  compressedBytes: 压缩,
                  purgeableBytes: 可丢弃,
                  speculativeBytes: 预读)
    }

    /// 物理内存总容量字节（等同 `totalBytes`）
    var 总容量: UInt64 { totalBytes }
    /// 空闲内存字节（等同 `freeBytes`）
    var 空闲: UInt64 { freeBytes }
    /// 活跃内存字节（等同 `activeBytes`）
    var 活跃: UInt64 { activeBytes }
    /// 非活跃内存字节（等同 `inactiveBytes`）
    var 非活跃: UInt64 { inactiveBytes }
    /// 联动内存字节（等同 `wiredBytes`）
    var 联动: UInt64 { wiredBytes }
    /// 已压缩内存字节（等同 `compressedBytes`）
    var 压缩: UInt64 { compressedBytes }
    /// 可丢弃内存字节（等同 `purgeableBytes`）
    var 可丢弃: UInt64 { purgeableBytes }
    /// 预读内存字节（等同 `speculativeBytes`）
    var 预读: UInt64 { speculativeBytes }
    /// 可用内存字节（等同 `availableBytes`）
    var 可用字节: UInt64 { availableBytes }
    /// 已用内存字节（等同 `usedBytes`）
    var 已用字节: UInt64 { usedBytes }
    /// 内存使用率（等同 `usedPercent`）
    var 已用占比: Double { usedPercent }
    /// 内存使用率文本（等同 `usedPercentText`）
    var 已用占比文本: String { usedPercentText }
    /// 总容量文本（等同 `totalDescription`）
    var 总容量文本: String { totalDescription }
    /// 联动内存文本（等同 `wiredDescription`）
    var 联动文本: String { wiredDescription }
    /// 已压缩内存文本（等同 `compressedDescription`）
    var 压缩文本: String { compressedDescription }
    /// 中文多行摘要（等同 `text`）
    var 明细文本: String { text }
}
