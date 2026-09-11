import Foundation

/// 显卡（GPU）信息
///
/// 由 `SystemInfoKit.gpuInfo` 返回，数据来自 Metal 的系统默认设备（`MTLCreateSystemDefaultDevice()`）。
/// 取不到时返回 `nil`（如模拟器、无 Metal 设备的极端环境）。
///
/// - Note: 多显卡机型（如带独显的 Intel Mac）这里只给出**系统默认设备**这一块。
///
/// - Example:
///   ```swift
///   if let 显卡 = SystemInfoKit.gpuInfo {
///       print(显卡.text)      // Apple M1 Pro · 统一内存 · 5461 MB
///   }
///   ```
public struct GPUInfo: Hashable {

    /// 显卡名称（形如 `Apple M1 Pro`）
    public let name: String
    /// 建议的最大工作集内存（字节，取自 `recommendedMaxWorkingSetSize`；读不到为 `0`）
    ///
    /// - Note: 该 API 仅 iOS 16+ / macOS 10.12+ 提供；iOS 15 上读不到，恒为 `0`。
    public let maxWorkingMemoryBytes: UInt64
    /// 是否为统一内存架构（Apple Silicon / Apple 集成显卡为 `true`）
    public let hasUnifiedMemory: Bool
    /// 单个线程组允许的最大线程数（宽度，取自 `maxThreadsPerThreadgroup.width`）
    public let maxThreadsPerThreadgroup: Int

    /// 创建一份显卡信息
    /// - Parameters:
    ///   - name: 显卡名称
    ///   - maxWorkingMemoryBytes: 建议最大工作集内存（字节）
    ///   - hasUnifiedMemory: 是否统一内存架构
    ///   - maxThreadsPerThreadgroup: 单线程组最大线程数（宽度）
    public init(name: String, maxWorkingMemoryBytes: UInt64, hasUnifiedMemory: Bool, maxThreadsPerThreadgroup: Int) {
        self.name = name
        self.maxWorkingMemoryBytes = maxWorkingMemoryBytes
        self.hasUnifiedMemory = hasUnifiedMemory
        self.maxThreadsPerThreadgroup = maxThreadsPerThreadgroup
    }

    /// 建议最大工作集内存（人类可读，形如 `5461 MB`）
    public var maxWorkingMemory: String {
        ByteCountFormatter.string(fromByteCount: Int64(maxWorkingMemoryBytes), countStyle: .memory)
    }

    /// 中文单行摘要（形如 `Apple M1 Pro · 统一内存 · 5461 MB`）
    public var text: String {
        var parts: [String] = [name]
        if hasUnifiedMemory {
            parts.append("统一内存")
        }
        if maxWorkingMemoryBytes > 0 {
            parts.append(maxWorkingMemory)
        }
        return parts.joined(separator: " · ")
    }
}

// MARK: 中文命名别名

/// 中文名：显卡信息（等同 `GPUInfo`）
public typealias 显卡信息 = GPUInfo

public extension GPUInfo {

    /// 创建一份显卡信息（中文参数）
    /// - Parameters:
    ///   - 名称: 显卡名称
    ///   - 最大工作内存字节: 建议最大工作集内存（字节）
    ///   - 统一内存: 是否统一内存架构
    ///   - 最大线程组: 单线程组最大线程数（宽度）
    init(名称: String, 最大工作内存字节: UInt64, 统一内存: Bool, 最大线程组: Int) {
        self.init(name: 名称,
                  maxWorkingMemoryBytes: 最大工作内存字节,
                  hasUnifiedMemory: 统一内存,
                  maxThreadsPerThreadgroup: 最大线程组)
    }

    /// 显卡名称（等同 `name`）
    var 名称: String { name }
    /// 建议最大工作集内存字节（等同 `maxWorkingMemoryBytes`）
    var 最大工作内存字节: UInt64 { maxWorkingMemoryBytes }
    /// 是否统一内存架构（等同 `hasUnifiedMemory`）
    var 统一内存: Bool { hasUnifiedMemory }
    /// 单线程组最大线程数（等同 `maxThreadsPerThreadgroup`）
    var 最大线程组: Int { maxThreadsPerThreadgroup }
    /// 建议最大工作集内存（等同 `maxWorkingMemory`）
    var 最大工作内存: String { maxWorkingMemory }
}
