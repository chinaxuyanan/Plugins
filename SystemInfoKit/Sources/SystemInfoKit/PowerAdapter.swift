import Foundation

/// 电源适配器明细（macOS）
///
/// 由 `SystemInfoKit.powerAdapter` 返回，数据来自 IOKit 的
/// `IOPSCopyExternalPowerAdapterDetails()`：**只有插着适配器时才有值**，
/// 用电池供电（或台式机无内置电池）时返回 `nil`。
///
/// 电压 / 电流是多口充电器的**协商值**（USB-C PD 会随电量动态调整），不是恒定的额定参数。
///
/// - Example:
///   ```swift
///   if let 适配器 = SystemInfoKit.powerAdapter {
///       print(适配器.text)      // 适配器 96W · 20.0V · 4.80A
///   } else {
///       print("未接电源")       // 用电池 / 台式机
///   }
///   ```
public struct PowerAdapter: Hashable {

    /// 适配器功率（瓦；读不到为 `nil`）
    public let watts: Int?
    /// 协商电压（毫伏；读不到为 `nil`）
    public let voltageMillivolts: Int?
    /// 协商电流（毫安；读不到为 `nil`）
    public let currentMilliamps: Int?
    /// 适配器标识（IOKit 的 `AdapterID`；读不到为 `nil`）
    public let adapterID: Int?

    /// 创建一份适配器明细
    /// - Parameters:
    ///   - watts: 适配器功率（瓦）
    ///   - voltageMillivolts: 协商电压（毫伏）
    ///   - currentMilliamps: 协商电流（毫安）
    ///   - adapterID: 适配器标识
    public init(watts: Int?, voltageMillivolts: Int?, currentMilliamps: Int?, adapterID: Int?) {
        self.watts = watts
        self.voltageMillivolts = voltageMillivolts
        self.currentMilliamps = currentMilliamps
        self.adapterID = adapterID
    }

    /// 功率文本（形如 `96W`；读不到为「未知」）
    public var wattsText: String {
        guard let watts else { return "未知" }
        return "\(watts)W"
    }

    /// 电压文本（形如 `20.0V`；读不到为「未知」）
    public var voltageText: String {
        guard let voltageMillivolts else { return "未知" }
        return String(format: "%.1fV", Double(voltageMillivolts) / 1000)
    }

    /// 电流文本（形如 `4.80A`；读不到为「未知」）
    public var currentText: String {
        guard let currentMilliamps else { return "未知" }
        return String(format: "%.2fA", Double(currentMilliamps) / 1000)
    }

    /// 中文单行摘要（形如 `适配器 96W · 20.0V · 4.80A`，缺项自动省略）
    public var text: String {
        var parts = ["适配器"]
        if watts != nil { parts.append(wattsText) }
        if voltageMillivolts != nil { parts.append(voltageText) }
        if currentMilliamps != nil { parts.append(currentText) }
        return parts.joined(separator: " · ")
    }
}

// MARK: 中文命名别名

/// 中文名：电源适配器（等同 `PowerAdapter`）
public typealias 电源适配器 = PowerAdapter

public extension PowerAdapter {

    /// 创建一份适配器明细（中文参数）
    /// - Parameters:
    ///   - 功率: 适配器功率（瓦）
    ///   - 电压毫伏: 协商电压（毫伏）
    ///   - 电流毫安: 协商电流（毫安）
    ///   - 标识: 适配器标识
    init(功率: Int?, 电压毫伏: Int?, 电流毫安: Int?, 标识: Int?) {
        self.init(watts: 功率,
                  voltageMillivolts: 电压毫伏,
                  currentMilliamps: 电流毫安,
                  adapterID: 标识)
    }

    /// 适配器功率（等同 `watts`）
    var 功率: Int? { watts }
    /// 协商电压毫伏（等同 `voltageMillivolts`）
    var 电压毫伏: Int? { voltageMillivolts }
    /// 协商电流毫安（等同 `currentMilliamps`）
    var 电流毫安: Int? { currentMilliamps }
    /// 适配器标识（等同 `adapterID`）
    var 标识: Int? { adapterID }
    /// 功率文本（等同 `wattsText`）
    var 功率文本: String { wattsText }
    /// 电压文本（等同 `voltageText`）
    var 电压文本: String { voltageText }
    /// 电流文本（等同 `currentText`）
    var 电流文本: String { currentText }
}
