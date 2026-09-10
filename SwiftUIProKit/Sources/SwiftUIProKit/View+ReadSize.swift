import SwiftUI

// MARK: - 尺寸读取

/// 视图尺寸偏好键（内部使用，勿在库外引用）
private struct ViewSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

public extension View {

    /// 读取视图实际尺寸
    ///
    /// 在视图背后铺一层透明 `GeometryReader` 测量其渲染尺寸，尺寸变化（含首次出现）时回调。
    /// 常用于「根据内容尺寸做自适应布局 / 折叠 / 绘图」等场景。
    ///
    /// - Parameter onChange: 尺寸变化回调，参数为当前 `CGSize`
    ///
    /// - Example:
    ///   ```swift
    ///   @State private var size: CGSize = .zero
    ///
    ///   Text("动态内容")
    ///       .readSize { size = $0 }
    ///       .frame(width: size.width, height: size.height)
    ///   ```
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ViewSizePreferenceKey.self, value: geo.size)
            }
        )
        .onPreferenceChange(ViewSizePreferenceKey.self, perform: onChange)
    }
}
