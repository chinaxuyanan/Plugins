import Foundation

// MARK: - LogEntry 序列化
//
// 把一条日志转成 JSON 可用的字典 / 字符串，方便配合 `LogKit.onLog` 回调
// 把日志转投到自有采集系统（上报服务端、写入数据库等）。

public extension LogEntry {

    /// 转成 JSON 可序列化的字典
    ///
    /// 键与 LogKit 内置的 `.json` 输出保持一致（`time` / `level` / `levelValue` /
    /// `category` / `message` / `file` / `line` / `traceId` / `fields`）。
    /// 位置字段仅在 `LogKit.showLocation` 打开时出现；`fields` 中的值会被规整为
    /// JSON 可序列化的基础类型。
    var jsonObject: [String: Any] {
        var dict: [String: Any] = [
            "time": timestamp,
            "level": level.chineseName,
            "levelValue": level.rawValue,
            "category": category,
            "message": message
        ]
        if let traceId = traceId {
            dict["traceId"] = traceId
        }
        if let file = file {
            dict["file"] = file
        }
        if let line = line {
            dict["line"] = line
        }
        if !fields.isEmpty {
            dict["fields"] = fields.mapValues { entryJSONSafe($0) }
        }
        return dict
    }

    /// 转成单行 JSON 字符串
    ///
    /// 序列化失败时返回空字符串（正常情况不会发生）。
    ///
    /// 键按字典序输出（`JSONSerialization` 的 `.sortedKeys`），同一份内容多次序列化结果完全一致，
    /// 方便对比 / 去重 / 测试断言。
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.onLog = { entry in
    ///       uploader.send(entry.jsonString)
    ///   }
    ///   ```
    var jsonString: String {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.sortedKeys]),
              let json = String(data: data, encoding: .utf8) else {
            return ""
        }
        return json
    }
}

/// 把任意字段值规整为 JSON 可序列化的值（非基础类型 / 非集合则转字符串），保证序列化不失败。
private func entryJSONSafe(_ value: Any) -> Any {
    switch value {
    case let s as String:
        return s
    case let b as Bool:
        return b
    case let n as NSNumber:
        return n
    case let a as [Any]:
        return a.map { entryJSONSafe($0) }
    case let d as [String: Any]:
        return d.mapValues { entryJSONSafe($0) }
    default:
        return String(describing: value)
    }
}
