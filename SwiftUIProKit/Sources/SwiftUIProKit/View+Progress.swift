import SwiftUI

// MARK: - 进度

public extension View {

    /// 线性进度样式
    ///
    /// ProgressView 以线性进度条显示，等效于 `.progressViewStyle(.linear)`。
    @ViewBuilder
    func progressStyleLinear() -> some View { progressViewStyle(.linear) }

    /// 圆形进度样式
    ///
    /// ProgressView 以圆形转圈显示，等效于 `.progressViewStyle(.circular)`。
    @ViewBuilder
    func progressStyleCircular() -> some View { progressViewStyle(.circular) }
}
