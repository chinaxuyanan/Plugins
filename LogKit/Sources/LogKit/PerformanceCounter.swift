import Foundation

/// 性能计数器：累计统计一段代码的执行表现
///
/// 与 `LogKit.measure`（每次调用都单独输出一条耗时日志）不同，`PerformanceCounter`
/// 只负责**累计**：记录某段代码（如「图片解码」「网络解析」）的调用次数、总耗时、
/// 平均 / 最大 / 最小耗时，等你想看时再 `report()` 输出一条汇总日志。
/// 适合性能回归监控——持续记录、按需汇报，不会刷屏。
///
/// - Example:
///   ```swift
///   let 解码 = PerformanceCounter("图片解码")
///   for _ in 0..<100 { 解码.measure { imageLoader.decode(data) } }
///   解码.report()   // → [调试] [通用] 「图片解码」调用 100 次 · 总耗时 1.20 s · ...
///   ```
///
/// 内部加锁，可在多个线程同时记录。
public final class PerformanceCounter {

    /// 计数器名称（用于汇总描述）
    public let name: String

    private let lock = NSLock()
    private var countValue = 0
    private var totalValue: TimeInterval = 0
    private var maxValue: TimeInterval = 0
    private var minValue: TimeInterval = .greatestFiniteMagnitude

    /// - Parameter name: 计数器名称（如「图片解码」）
    public init(_ name: String) {
        self.name = name
    }

    // MARK: 记录

    /// 手动记录一次耗时
    ///
    /// - Parameter duration: 本次耗时（秒），可来自你自己的计时逻辑
    public func record(_ duration: TimeInterval) {
        lock.lock()
        defer { lock.unlock() }
        countValue += 1
        totalValue += duration
        if duration > maxValue { maxValue = duration }
        if duration < minValue { minValue = duration }
    }

    /// 计时执行一段同步代码，自动累计其耗时并返回结果
    ///
    /// 代码块抛错时同样会累计耗时，然后把错误原样抛出。
    @discardableResult
    public func measure<T>(_ block: () throws -> T) rethrows -> T {
        let start = Date()
        defer { record(Date().timeIntervalSince(start)) }
        return try block()
    }

    /// 计时执行一段异步代码，自动累计其耗时（`async` 版本）
    @discardableResult
    public func measureAsync<T>(_ block: () async throws -> T) async rethrows -> T {
        let start = Date()
        defer { record(Date().timeIntervalSince(start)) }
        return try await block()
    }

    // MARK: 汇总

    /// 累计调用次数
    public var callCount: Int {
        lock.lock(); defer { lock.unlock() }
        return countValue
    }

    /// 累计总耗时（秒）
    public var totalDuration: TimeInterval {
        lock.lock(); defer { lock.unlock() }
        return totalValue
    }

    /// 平均耗时（秒），未记录过时为 `0`
    public var averageDuration: TimeInterval {
        lock.lock(); defer { lock.unlock() }
        return countValue == 0 ? 0 : totalValue / Double(countValue)
    }

    /// 最大单次耗时（秒），未记录过时为 `0`
    public var maxDuration: TimeInterval {
        lock.lock(); defer { lock.unlock() }
        return countValue == 0 ? 0 : maxValue
    }

    /// 最小单次耗时（秒），未记录过时为 `0`
    public var minDuration: TimeInterval {
        lock.lock(); defer { lock.unlock() }
        return countValue == 0 ? 0 : minValue
    }

    /// 生成汇总描述字符串（不输出日志）
    ///
    /// 形如 `「图片解码」调用 100 次 · 总耗时 1.20 s · 平均 12.0 ms · 最大 45.0 ms · 最小 3.2 ms`
    public func summary() -> String {
        lock.lock(); defer { lock.unlock() }
        let avg = countValue == 0 ? 0 : totalValue / Double(countValue)
        let min = countValue == 0 ? 0 : minValue
        return "「\(name)」调用 \(countValue) 次 · 总耗时 \(format(totalValue)) · 平均 \(format(avg)) · 最大 \(format(maxValue)) · 最小 \(format(min))"
    }

    /// 通过 LogKit 输出一条汇总日志
    ///
    /// - Parameters:
    ///   - level: 日志级别，默认 `.debug`
    ///   - category: 分类名，默认「通用」
    public func report(level: LogLevel = .debug, category: String = "通用") {
        let text = summary()
        switch level {
        case .debug: LogKit.debug(text, category: category)
        case .info: LogKit.info(text, category: category)
        case .warning: LogKit.warning(text, category: category)
        case .error: LogKit.error(text, category: category)
        case .critical: LogKit.critical(text, category: category)
        }
    }

    /// 清零所有累计数据，重新开始统计
    public func reset() {
        lock.lock(); defer { lock.unlock() }
        countValue = 0
        totalValue = 0
        maxValue = 0
        minValue = .greatestFiniteMagnitude
    }

    // MARK: 内部

    /// 把耗时格式化为人类可读字符串（毫秒 / 秒）
    private func format(_ interval: TimeInterval) -> String {
        if interval < 1 {
            return String(format: "%.1f ms", interval * 1000)
        }
        return String(format: "%.2f s", interval)
    }
}

// MARK: 中文命名别名

/// 中文名：性能计数器（等同 `PerformanceCounter`）
public typealias 性能计数器 = PerformanceCounter

public extension PerformanceCounter {
    /// 性能计数器（中文参数）
    /// - Parameter 名称: 计数器名称（如「图片解码」）
    convenience init(名称: String) {
        self.init(名称)
    }

    /// 手动记录一次耗时（等同 `record`）
    func 记录(_ 耗时: TimeInterval) { record(耗时) }

    /// 计时执行一段同步代码（等同 `measure`）
    @discardableResult
    func 计时<T>(_ 代码块: () throws -> T) rethrows -> T {
        try measure(代码块)
    }

    /// 计时执行一段异步代码（等同 `measureAsync`）
    @discardableResult
    func 异步计时<T>(_ 代码块: () async throws -> T) async rethrows -> T {
        try await measureAsync(代码块)
    }

    /// 累计调用次数（等同 `callCount`）
    var 调用次数: Int { callCount }

    /// 累计总耗时（等同 `totalDuration`）
    var 总耗时: TimeInterval { totalDuration }

    /// 平均耗时（等同 `averageDuration`）
    var 平均耗时: TimeInterval { averageDuration }

    /// 最大单次耗时（等同 `maxDuration`）
    var 最大耗时: TimeInterval { maxDuration }

    /// 最小单次耗时（等同 `minDuration`）
    var 最小耗时: TimeInterval { minDuration }

    /// 生成汇总描述字符串（等同 `summary`）
    func 汇总() -> String { summary() }

    /// 输出一条汇总日志（等同 `report`）
    func 输出报告(级别: LogLevel = .debug, 分类: String = "通用") {
        report(level: 级别, category: 分类)
    }

    /// 清零重新统计（等同 `reset`）
    func 重置() { reset() }
}
