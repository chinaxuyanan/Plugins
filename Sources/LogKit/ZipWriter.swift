import Foundation

/// 极简 ZIP 打包器（纯 Foundation，无第三方依赖）
///
/// 只用「存储」方式（STORED，不压缩）打包：无需 zlib，文件内容原样写入，
/// 任何解压工具（macOS 访达、Windows 资源管理器、`unzip`）都能打开。
/// 日志本就是文本、体积不大，打包的目的是「一次带走全部文件」而非压体积。
///
/// - Note: 单次打包上限 4 GB（ZIP 存储方式用的是 32 位长度字段），日志场景足够。
enum ZipWriter {

    /// 待打包的一个文件
    struct Entry {
        /// 包内文件名（一般直接用原文件名）
        let name: String
        /// 文件内容
        let data: Data
        /// 文件修改时间（写进 ZIP 头，解压后即为此时间）
        let modificationDate: Date
    }

    /// 把若干文件打包成一个 ZIP 的字节流
    ///
    /// 结构为标准的「本地文件头 + 文件数据 …… + 中央目录 + 目录结束记录」。
    /// 传入空数组时会生成一个「只含目录结束记录」的合法空 ZIP。
    ///
    /// - Parameter entries: 待打包的文件（顺序即包内顺序）
    /// - Returns: ZIP 字节流
    static func archive(_ entries: [Entry]) -> Data {
        var output = Data()
        var centralDirectory = Data()

        for entry in entries {
            let crc = crc32(entry.data)
            let size = UInt32(entry.data.count)
            let nameBytes = Array(entry.name.utf8)
            let stamp = dosDateTime(entry.modificationDate)
            let localOffset = UInt32(output.count)

            // 本地文件头
            output.append(le32: 0x04034b50)
            output.append(le16: 20)         // 解压所需版本（2.0）
            output.append(le16: 0x0800)     // 标志位：文件名为 UTF-8
            output.append(le16: 0)          // 压缩方式：0 = 存储（不压缩）
            output.append(le16: stamp.time)
            output.append(le16: stamp.date)
            output.append(le32: crc)
            output.append(le32: size)       // 压缩后大小（存储方式下等于原始大小）
            output.append(le32: size)       // 原始大小
            output.append(le16: UInt16(nameBytes.count))
            output.append(le16: 0)          // 扩展字段长度
            output.append(contentsOf: nameBytes)
            output.append(entry.data)

            // 中央目录项
            centralDirectory.append(le32: 0x02014b50)
            centralDirectory.append(le16: 20)   // 制作版本
            centralDirectory.append(le16: 20)   // 解压所需版本
            centralDirectory.append(le16: 0x0800)
            centralDirectory.append(le16: 0)
            centralDirectory.append(le16: stamp.time)
            centralDirectory.append(le16: stamp.date)
            centralDirectory.append(le32: crc)
            centralDirectory.append(le32: size)
            centralDirectory.append(le32: size)
            centralDirectory.append(le16: UInt16(nameBytes.count))
            centralDirectory.append(le16: 0)    // 扩展字段长度
            centralDirectory.append(le16: 0)    // 注释长度
            centralDirectory.append(le16: 0)    // 起始磁盘号
            centralDirectory.append(le16: 0)    // 内部属性
            centralDirectory.append(le32: 0)    // 外部属性
            centralDirectory.append(le32: localOffset)
            centralDirectory.append(contentsOf: nameBytes)
        }

        let centralOffset = UInt32(output.count)
        output.append(centralDirectory)
        let centralSize = UInt32(output.count) - centralOffset
        let count = UInt16(min(entries.count, Int(UInt16.max)))

        // 中央目录结束记录
        output.append(le32: 0x06054b50)
        output.append(le16: 0)              // 当前磁盘号
        output.append(le16: 0)              // 中央目录起始磁盘号
        output.append(le16: count)          // 本磁盘上的条目数
        output.append(le16: count)          // 总条目数
        output.append(le32: centralSize)
        output.append(le32: centralOffset)
        output.append(le16: 0)              // 注释长度
        return output
    }

    /// 计算 CRC-32 校验值（ZIP 与 PNG 用的标准算法，多项式 `0xEDB88320`）
    ///
    /// - Parameter data: 原始字节
    /// - Returns: 校验值（如 `"123456789"` 得到 `0xCBF43926`）
    static func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFFFFFF
        for byte in data {
            crc ^= UInt32(byte)
            for _ in 0..<8 {
                if crc & 1 == 1 {
                    crc = (crc >> 1) ^ 0xEDB88320
                } else {
                    crc >>= 1
                }
            }
        }
        return crc ^ 0xFFFFFFFF
    }

    /// 把时刻转成 ZIP 使用的 MS-DOS 时间 / 日期字段
    ///
    /// - Parameter date: 时刻
    /// - Returns: `time`（时 / 分 / 秒÷2）与 `date`（年-1980 / 月 / 日）
    static func dosDateTime(_ date: Date) -> (time: UInt16, date: UInt16) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = LogKit.timeZone
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let year = max(1980, parts.year ?? 1980)
        let time = UInt16(((parts.hour ?? 0) << 11) | ((parts.minute ?? 0) << 5) | ((parts.second ?? 0) / 2))
        let day = UInt16(((year - 1980) << 9) | ((parts.month ?? 1) << 5) | (parts.day ?? 1))
        return (time, day)
    }
}

private extension Data {

    /// 追加一个 16 位小端整数
    mutating func append(le16 value: UInt16) {
        append(UInt8(value & 0xFF))
        append(UInt8((value >> 8) & 0xFF))
    }

    /// 追加一个 32 位小端整数
    mutating func append(le32 value: UInt32) {
        append(UInt8(value & 0xFF))
        append(UInt8((value >> 8) & 0xFF))
        append(UInt8((value >> 16) & 0xFF))
        append(UInt8((value >> 24) & 0xFF))
    }
}
