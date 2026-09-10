import SwiftUI
import Combine

// MARK: - 生命周期与订阅
//
// 视图出现 / 消失、值变化、发布者订阅、异步任务等生命周期相关属性的语义化封装。

public extension View {

    /// 视图出现时执行
    ///
    /// 等效于 `.onAppear(perform:)`。
    ///
    /// - Parameter action: 视图出现时执行的操作
    ///
    /// - Example:
    ///   ```swift
    ///   Text("内容").didAppear { 加载数据() }
    ///   ```
    @ViewBuilder
    func didAppear(_ action: @escaping () -> Void) -> some View {
        onAppear(perform: action)
    }

    /// 视图消失时执行
    ///
    /// 等效于 `.onDisappear(perform:)`。
    ///
    /// - Parameter action: 视图消失时执行的操作
    @ViewBuilder
    func didDisappear(_ action: @escaping () -> Void) -> some View {
        onDisappear(perform: action)
    }

    /// 值变化时执行
    ///
    /// 等效于 `.onChange(of:perform:)`，iOS 17 / macOS 14 起自动切换到新 API。
    ///
    /// - Parameters:
    ///   - value: 监听的等值类型值
    ///   - action: 值变化后执行的操作，参数为新值
    ///
    /// - Example:
    ///   ```swift
    ///   Text("选中").didChange(of: 选中项) { 新值 in
    ///       处理(新值)
    ///   }
    ///   ```
    @ViewBuilder
    func didChange<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            onChange(of: value) { _, newValue in action(newValue) }
        } else {
            onChange(of: value, perform: action)
        }
    }

    /// 订阅发布者，收到值变化时执行
    ///
    /// 等效于 `.onReceive(_:perform:)`，可监听通知、定时器等 Combine 发布者。
    ///
    /// - Parameters:
    ///   - publisher: Combine 发布者
    ///   - action: 收到新值后执行的操作
    @ViewBuilder
    func didReceive<P: Publisher>(_ publisher: P, perform action: @escaping (P.Output) -> Void) -> some View where P.Failure == Never {
        onReceive(publisher, perform: action)
    }

    /// 异步任务（视图出现时启动、消失时自动取消）
    ///
    /// 等效于 `.task(priority:_:)`。
    ///
    /// - Parameters:
    ///   - priority: 任务优先级，默认 `.userInitiated`
    ///   - action: 异步操作
    ///
    /// - Example:
    ///   ```swift
    ///   List { ... }.asyncTask { await 拉取数据() }
    ///   ```
    @ViewBuilder
    func asyncTask(priority: TaskPriority = .userInitiated, _ action: @escaping @Sendable () async -> Void) -> some View {
        task(priority: priority, action)
    }
}
