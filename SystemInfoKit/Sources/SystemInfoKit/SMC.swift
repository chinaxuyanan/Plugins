import Foundation
#if os(macOS)
import Darwin
import IOKit
#endif

// MARK: - 风扇转速与整机温度（SMC）
//
// Mac 的风扇转速与温度传感器没有公开的系统 API，只能读 SMC（系统管理控制器）。
// 这里用 IOKit 的 `AppleSMC` 服务 + `IOConnectCallStructMethod`，按 SMC 的键值协议读数据：
//   1. 先以 `READ_KEYINFO`(9) 问出该键的数据长度与数据类型；
//   2. 再以 `READ_BYTES`(5) 取回最多 32 字节的数据。
// 数据类型决定解码方式：`sp78`（有符号 7.8 定点，温度）、`fpe2`（无符号定点，转速）、`flt `（大端浮点）。
//
// 一切读不到的情况（无 SMC、无该键、机型无风扇）都优雅降级为 `nil` / 空数组，不抛错。

public extension SystemInfoKit {

    /// 所有风扇的转速（macOS；无风扇机型 / 读取不到 / iOS 时为空数组）
    ///
    /// 通过 SMC 的 `FNum` 问出风扇数量，再逐个读 `F0Ac` / `F1Ac`…（当前实际转速，`fpe2` 定点）。
    ///
    /// - Example:
    ///   ```swift
    ///   for 风扇 in SystemInfoKit.fanSpeeds {
    ///       print("\(风扇.index): \(风扇.rpm) RPM")
    ///   }
    ///   ```
    static var fanSpeeds: [FanSpeed] {
        #if os(macOS)
        guard let connection = smcConnection() else { return [] }
        defer { IOServiceClose(connection) }

        var fans: [FanSpeed] = []
        let declared = Int(smcRead(connection, key: "FNum").flatMap(smcScalar) ?? 0)
        // 数量读不到时按最多 4 个试探，读到几个算几个
        let limit = declared > 0 ? min(declared, 12) : 4
        for index in 0..<limit {
            guard let rpm = smcRead(connection, key: "F\(index)Ac").flatMap(smcScalar) else { continue }
            fans.append(FanSpeed(index: index, rpm: Int(rpm.rounded())))
        }
        return fans
        #else
        return []
        #endif
    }

    /// 所有风扇转速的单行文本（形如 `风扇 0：2400 RPM`；无风扇或读取不到返回「无风扇或读取不到」）
    static var fanSpeedsText: String {
        let fans = fanSpeeds
        guard !fans.isEmpty else { return "无风扇或读取不到" }
        return fans.map(\.text).joined(separator: " · ")
    }

    /// 整机温度（摄氏度；取若干常见温度传感器中的最高值，读不到或非 macOS 返回 `nil`）
    ///
    /// 依次尝试 CPU / GPU / 电池附近的常见 SMC 温度键（`TC0P`、`TG0P`、`TB0T`、Apple Silicon 的 `Tp0x` 等），
    /// 取其中最可信的一条（读数落在 0 ~ 120 ℃ 内）。**这是传感器读数中的最高值**，
    /// 不代表某个固定部位的温度；要更细的分项需自行按机型补键。
    ///
    /// - Example:
    ///   ```swift
    ///   print(SystemInfoKit.machineTemperatureText)   // 46.5 ℃
    ///   ```
    static var machineTemperature: Double? {
        #if os(macOS)
        guard let connection = smcConnection() else { return nil }
        defer { IOServiceClose(connection) }

        var readings: [Double] = []
        for key in machineTemperatureKeys {
            guard let value = smcRead(connection, key: key).flatMap(smcScalar) else { continue }
            // 明显异常的读数（0 或超出人体安全范围）视为无效
            guard value > 0, value < 120 else { continue }
            readings.append(value)
        }
        return readings.max()
        #else
        return nil
        #endif
    }

    /// 整机温度文本（形如 `46.5 ℃`；读取不到或非 macOS 返回「不支持」）
    static var machineTemperatureText: String {
        guard let celsius = machineTemperature else { return "不支持" }
        return String(format: "%.1f ℃", celsius)
    }
}

#if os(macOS)

/// SMC 键的数据类型 / 长度 / 数据体
private struct SMCReading {
    let dataType: UInt32
    let size: Int
    let bytes: SMCBytes
}

/// 内部：SMC 数据体的 32 个字节（按内存顺序访问单独某个字节）
private struct SMCBytes {
    var values: (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
    ) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

    /// 按下标读写单个字节（越界读返回 0，越界写忽略）
    subscript(index: Int) -> UInt8 {
        get {
            withUnsafeBytes(of: values) { raw in
                (index >= 0 && index < raw.count) ? raw[index] : 0
            }
        }
        set {
            guard index >= 0, index < MemoryLayout.size(ofValue: values) else { return }
            withUnsafeMutableBytes(of: &values) { raw in
                raw[index] = newValue
            }
        }
    }
}

/// 内部：SMC 的版本字段
private struct SMCVersion {
    var major: UInt8 = 0
    var minor: UInt8 = 0
    var build: UInt8 = 0
    var reserved: UInt8 = 0
    var release: UInt16 = 0
}

/// 内部：SMC 的功率限制字段（本库不使用，仅为对齐结构体布局）
private struct SMCPrivateLimit {
    var version: UInt16 = 0
    var length: UInt16 = 0
    var cpuLimit: UInt32 = 0
    var gpuLimit: UInt32 = 0
    var memoryLimit: UInt32 = 0
}

/// 内部：SMC 的键信息（数据长度 / 数据类型 / 属性）
private struct SMCKeyInfo {
    var dataSize: UInt32 = 0
    var dataType: UInt32 = 0
    var dataAttributes: UInt8 = 0
}

/// 内部：SMC `IOConnectCallStructMethod` 的入参 / 出参结构体
///
/// 字段顺序与类型必须与内核侧的结构体一致，Swift 的布局规则与 C 相同，逐字段对齐即可。
private struct SMCKeyData {
    var key: UInt32 = 0
    var vers = SMCVersion()
    var pLimitData = SMCPrivateLimit()
    var keyInfo = SMCKeyInfo()
    var result: UInt8 = 0
    var status: UInt8 = 0
    var data8: UInt8 = 0
    var data32: UInt32 = 0
    var bytes = SMCBytes()
}

/// 内部：SMC 的读命令选择子（用户客户端下标）
private let smcKernelIndex: UInt32 = 2
/// 内部：读取数据体
private let smcCommandReadBytes: UInt8 = 5
/// 内部：读取键信息
private let smcCommandReadKeyInfo: UInt8 = 9

/// 内部：整机温度候选键（CPU / GPU / 电池附近 / Apple Silicon 常见探头）
private let machineTemperatureKeys = [
    "TC0P", "TC0D", "TC0E", "TC0F", "TC0H", "TC1C", "TC2C",
    "TG0P", "TG0D",
    "TB0T", "TB1T", "TB2T",
    "Tp01", "Tp05", "Tp09", "Tp0D"
]

/// 内部：把 4 个 ASCII 字符包成一个 `UInt32` 键（首位在高位字节）
private func smcFourCharCode(_ text: String) -> UInt32 {
    var value: UInt32 = 0
    for byte in text.utf8.prefix(4) {
        value = (value << 8) | UInt32(byte)
    }
    return value
}

/// 内部：把 `UInt32` 数据类型还原成 4 字符串（补位的 NUL 换成空格，便于 `switch` 比较）
private func smcTypeName(_ code: UInt32) -> String {
    let bytes = [UInt8((code >> 24) & 0xFF),
                 UInt8((code >> 16) & 0xFF),
                 UInt8((code >> 8) & 0xFF),
                 UInt8(code & 0xFF)]
    let text = String(bytes: bytes, encoding: .ascii) ?? ""
    return text.replacingOccurrences(of: "\0", with: " ")
}

/// 内部：打开 `AppleSMC` 服务并建立用户客户端连接（失败返回 `nil`）
private func smcConnection() -> io_connect_t? {
    guard let matching = IOServiceMatching("AppleSMC") else { return nil }
    let service = IOServiceGetMatchingService(kIOMainPortDefault, matching)
    guard service != 0 else { return nil }
    defer { IOObjectRelease(service) }

    var connection: io_connect_t = 0
    guard IOServiceOpen(service, mach_task_self_, 0, &connection) == KERN_SUCCESS else { return nil }
    return connection
}

/// 内部：读取某个 SMC 键的原始数据（先问键信息、再读数据体）
private func smcRead(_ connection: io_connect_t, key: String) -> SMCReading? {
    let code = smcFourCharCode(key)
    let size = MemoryLayout<SMCKeyData>.stride

    // 第一步：READ_KEYINFO 问出数据长度与类型
    var infoInput = SMCKeyData()
    infoInput.key = code
    infoInput.data8 = smcCommandReadKeyInfo
    var infoOutput = SMCKeyData()
    var infoOutputSize = size
    var result = IOConnectCallStructMethod(connection, smcKernelIndex,
                                           &infoInput, size, &infoOutput, &infoOutputSize)
    guard result == KERN_SUCCESS, infoOutput.result == 0 else { return nil }

    let dataSize = Int(infoOutput.keyInfo.dataSize)
    let dataType = infoOutput.keyInfo.dataType
    guard dataSize > 0, dataSize <= 32 else { return nil }

    // 第二步：READ_BYTES 取回数据体
    var dataInput = SMCKeyData()
    dataInput.key = code
    dataInput.keyInfo.dataSize = infoOutput.keyInfo.dataSize
    dataInput.data8 = smcCommandReadBytes
    var dataOutput = SMCKeyData()
    var dataOutputSize = size
    result = IOConnectCallStructMethod(connection, smcKernelIndex,
                                       &dataInput, size, &dataOutput, &dataOutputSize)
    guard result == KERN_SUCCESS, dataOutput.result == 0 else { return nil }

    return SMCReading(dataType: dataType, size: dataSize, bytes: dataOutput.bytes)
}

/// 内部：把 SMC 数据按类型解码成数值
///
/// 支持 `sp78` / `sp87`（有符号 7.8 定点，温度）、`fpe2`（无符号定点 / 4，转速）、
/// `flt `（大端 IEEE754 单精度）、`ui8 ` / `ui16`（无符号整数）。
private func smcScalar(_ reading: SMCReading) -> Double? {
    let bytes = reading.bytes
    switch smcTypeName(reading.dataType) {
    case "sp78", "sp87":
        guard reading.size >= 2 else { return nil }
        let raw = UInt16(bytes[0]) << 8 | UInt16(bytes[1])
        return Double(Int16(bitPattern: raw)) / 256
    case "fpe2":
        guard reading.size >= 2 else { return nil }
        let raw = UInt16(bytes[0]) << 8 | UInt16(bytes[1])
        return Double(raw) / 4
    case "flt ":
        guard reading.size >= 4 else { return nil }
        let bits = UInt32(bytes[0]) << 24
            | UInt32(bytes[1]) << 16
            | UInt32(bytes[2]) << 8
            | UInt32(bytes[3])
        return Double(Float(bitPattern: bits))
    case "ui8 ", "ui8":
        return Double(bytes[0])
    case "ui16":
        guard reading.size >= 2 else { return nil }
        return Double(UInt16(bytes[0]) << 8 | UInt16(bytes[1]))
    default:
        return nil
    }
}

#endif
