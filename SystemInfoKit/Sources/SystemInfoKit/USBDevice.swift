import Foundation

/// 单个 USB 外设（macOS）
///
/// 由 `SystemInfoKit.usbDevices` 返回，数据来自 IOKit 的 `IOUSBHostDevice` 注册表节点。
/// 含产品名、厂商名、厂商 / 产品 ID 与序列号，字段缺失时对应属性为 `nil`。
/// 集线器、内建键盘 / 触控板等也会出现在列表里；iOS 上恒为空数组。
///
/// - Example:
///   ```swift
///   for 设备 in SystemInfoKit.usbDevices {
///       print(设备.text)      // 键盘 · Apple Inc. (05AC:0250)
///   }
///   ```
public struct USBDevice: Hashable {

    /// 产品名（读不到时为「未知设备」）
    public let name: String
    /// 厂商名（读不到为 `nil`）
    public let vendorName: String?
    /// 厂商 ID（十进制；读不到为 `nil`）
    public let vendorID: Int?
    /// 产品 ID（十进制；读不到为 `nil`）
    public let productID: Int?
    /// 序列号（读不到为 `nil`）
    public let serialNumber: String?

    /// 创建一个 USB 外设
    /// - Parameters:
    ///   - name: 产品名
    ///   - vendorName: 厂商名
    ///   - vendorID: 厂商 ID（十进制）
    ///   - productID: 产品 ID（十进制）
    ///   - serialNumber: 序列号
    public init(name: String, vendorName: String?, vendorID: Int?, productID: Int?, serialNumber: String?) {
        self.name = name
        self.vendorName = vendorName
        self.vendorID = vendorID
        self.productID = productID
        self.serialNumber = serialNumber
    }

    /// 厂商 / 产品 ID 文本（形如 `05AC:0250`，四位大写十六进制；缺项时只给能拿到的部分）
    public var idText: String? {
        let vendor = vendorID.map { String(format: "%04X", $0) }
        let product = productID.map { String(format: "%04X", $0) }
        switch (vendor, product) {
        case let (v?, p?): return "\(v):\(p)"
        case let (v?, nil): return v
        case let (nil, p?): return p
        default: return nil
        }
    }

    /// 中文单行摘要（形如 `键盘 · Apple Inc. (05AC:0250)`，缺项自动省略）
    public var text: String {
        var parts: [String] = [name]
        if let vendorName, !vendorName.isEmpty, vendorName != name {
            parts.append(vendorName)
        }
        if let idText {
            parts.append("(\(idText))")
        }
        return parts.joined(separator: " · ")
    }
}

// MARK: 中文命名别名

/// 中文名：USB 外设（等同 `USBDevice`）
public typealias USB设备 = USBDevice

public extension USBDevice {

    /// 创建一个 USB 外设（中文参数）
    /// - Parameters:
    ///   - 名称: 产品名
    ///   - 厂商: 厂商名
    ///   - 厂商ID: 厂商 ID（十进制）
    ///   - 产品ID: 产品 ID（十进制）
    ///   - 序列号: 序列号
    init(名称: String, 厂商: String?, 厂商ID: Int?, 产品ID: Int?, 序列号: String?) {
        self.init(name: 名称, vendorName: 厂商, vendorID: 厂商ID, productID: 产品ID, serialNumber: 序列号)
    }

    /// 产品名（等同 `name`）
    var 名称: String { name }
    /// 厂商名（等同 `vendorName`）
    var 厂商: String? { vendorName }
    /// 厂商 ID（等同 `vendorID`）
    var 厂商ID: Int? { vendorID }
    /// 产品 ID（等同 `productID`）
    var 产品ID: Int? { productID }
    /// 序列号（等同 `serialNumber`）
    var 序列号: String? { serialNumber }
    /// 厂商 / 产品 ID 文本（等同 `idText`）
    var 标识文本: String? { idText }
}
