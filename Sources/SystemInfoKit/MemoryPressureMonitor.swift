import Foundation
import Dispatch

#if os(macOS)

/// 内存压力监听器：实时监听系统内存压力变化
///
/// 系统内存压力发生变化（正常 → 警告 → 严重）时通过 `onPressureChange` 回调，
/// 适合在压力升高时主动释放缓存、降低资源占用。内部基于 `DispatchSource` 实现。
///
/// - Important: 仅 macOS 支持（`DispatchSource.makeMemoryPressureSource` 为 macOS 专有 API）。
///
/// - Example:
///   ```swift
///   let 监听 = MemoryPressureMonitor()
///   监听.onPressureChange = { event in
///       if event.contains(.critical) { 释放缓存() }
///   }
///   监听.start()
///   ```
public final class MemoryPressureMonitor {

    /// 当前内存压力（等同 `SystemInfoKit.memoryPressure`；无法确定时返回「正常」）
    public var currentPressure: DispatchSource.MemoryPressureEvent {
        SystemInfoKit.currentMemoryPressureEvent() ?? .normal
    }

    /// 内存压力变化回调（在 `start` 指定的队列上执行）
    public var onPressureChange: ((DispatchSource.MemoryPressureEvent) -> Void)?

    private var source: DispatchSourceMemoryPressure?

    public init() {}

    /// 是否正在监听
    public var isMonitoring: Bool { source != nil }

    /// 开始监听（重复调用会先停止旧监听）
    ///
    /// - Parameter queue: 回调执行的队列，默认主队列
    public func start(queue: DispatchQueue = .main) {
        stop()
        let newSource = DispatchSource.makeMemoryPressureSource(eventMask: .all, queue: queue)
        newSource.setEventHandler { [weak self] in
            self?.onPressureChange?(newSource.data)
        }
        newSource.resume()
        source = newSource
    }

    /// 停止监听
    public func stop() {
        source?.cancel()
        source = nil
    }

    deinit {
        stop()
    }
}

// MARK: 中文命名别名

/// 中文名：内存压力监听器（等同 `MemoryPressureMonitor`）
public typealias 内存压力监听器 = MemoryPressureMonitor

public extension MemoryPressureMonitor {
    /// 当前内存压力（等同 `currentPressure`）
    var 当前压力: DispatchSource.MemoryPressureEvent { currentPressure }

    /// 内存压力变化回调（等同 `onPressureChange`）
    var 压力变化回调: ((DispatchSource.MemoryPressureEvent) -> Void)? {
        get { onPressureChange }
        set { onPressureChange = newValue }
    }

    /// 是否正在监听（等同 `isMonitoring`）
    var 是否监听中: Bool { isMonitoring }

    /// 开始监听（等同 `start`）
    /// - Parameter 队列: 回调执行的队列，默认主队列
    func 开始监听(队列: DispatchQueue = .main) { start(queue: 队列) }

    /// 停止监听（等同 `stop`）
    func 停止监听() { stop() }
}

#endif
