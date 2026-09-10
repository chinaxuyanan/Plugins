import SwiftUI

// MARK: - 毛玻璃与材质

public extension View {

    /// 毛玻璃背景（超薄材质 `ultraThinMaterial`）
    ///
    /// 在内容后面垫一层模糊的半透明毛玻璃，常用于浮层、工具栏、卡片标题栏。
    func frostedGlass() -> some View {
        background(.ultraThinMaterial)
    }

    /// 材质背景
    ///
    /// - Parameter material: 系统材质，默认 `.regularMaterial`
    ///
    ///   可选：`.ultraThinMaterial` / `.thinMaterial` / `.regularMaterial` / `.thickMaterial` / `.ultraThickMaterial` / `.bar`
    func materialBackground(_ material: Material = .regularMaterial) -> some View {
        background(material)
    }
}
