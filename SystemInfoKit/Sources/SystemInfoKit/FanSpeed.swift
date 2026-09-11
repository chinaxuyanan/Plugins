import Foundation

/// 单个风扇的转速（macOS）
///
/// 由 `SystemInfoKit.fanSpeeds` 返回，数据来自 SMC（系统管理控制器）的 `FnAc` 键。
/// **只有带风扇的机型**（MacBook Pro / iMac / Mac mini 等，且非无风扇的 MacBook Air、无风扇 Apple Silicon 机型）
/// 才有内容；读不到时列表为空。iOS 恒为空数组。
///
/// - Example:
///   ```swift
///   for 风扇 in SystemInfoKit.fanSpeeds {
///       print(风扇.text)      // 风扇 0：2400 RPM
///   }
///   ```
public struct FanSpeed: Hashable {

    /// 风扇序号（从 `0` 开始，与 SMC 的 `F0` / `F1` 对应）
    public let index: Int
    /// 当前转速（转 / 分钟）
    public let rpm: Int

    /// 创建一个风扇转速
    /// - Parameters:
    ///   - index: 风扇序号（从 `0` 开始）
    ///   - rpm: 当前转速（转 / 分钟）
    public init(index: Int, rpm: Int) {
        self.index = index
        self.rpm = rpm
    }

    /// 中文单行摘要（形如 `风扇 0：2400 RPM`）
    public var text: String {
        "风扇 \(index)：\(rpm) RPM"
    }
}

// MARK: 中文命名别名

/// 中文名：风扇转速（等同 `FanSpeed`）
public typealias 风扇转速 = FanSpeed

public extension FanSpeed {

    /// 创建一个风扇转速（中文参数）
    /// - Parameters:
    ///   - 序号: 风扇序号（从 `0` 开始）
    ///   - 转速: 当前转速（转 / 分钟）
    init(序号: Int, 转速: Int) {
        self.init(index: 序号, rpm: 转速)
    }

    /// 风扇序号（等同 `index`）
    var 序号: Int { index }
    /// 当前转速（等同 `rpm`）
    var 转速: Int { rpm }
}
