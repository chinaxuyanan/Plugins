import SwiftUI

// MARK: - 中文命名别名
//
// 为每个英文封装方法提供中文命名的别名，让开发者在输入 `.` 触发自动补全时，
// 直接在候选列表里看到中文方法名，见名即选，无需先记住英文名。
// 每个中文别名等价转发到对应的英文方法（英文方法及其完整中文注释保留）。

// MARK: 布局与尺寸

public extension View {
    /// 占满父视图宽度（等同 `fillWidth`）
    /// - Parameter 对齐: 内容对齐方式，默认 `.center`
    @ViewBuilder
    func 占满宽度(对齐: Alignment = .center) -> some View {
        fillWidth(alignment: 对齐)
    }

    /// 占满父视图高度（等同 `fillHeight`）
    /// - Parameter 对齐: 内容对齐方式，默认 `.center`
    @ViewBuilder
    func 占满高度(对齐: Alignment = .center) -> some View {
        fillHeight(alignment: 对齐)
    }

    /// 同时占满父视图宽高（等同 `fillSpace`）
    /// - Parameter 对齐: 内容对齐方式，默认 `.center`
    @ViewBuilder
    func 占满空间(对齐: Alignment = .center) -> some View {
        fillSpace(alignment: 对齐)
    }

    /// 固定为正方形尺寸（等同 `size`）
    /// - Parameter 边长: 正方形边长，单位 pt
    @ViewBuilder
    func 正方形(边长: CGFloat) -> some View {
        size(边长)
    }

    /// 分别设置水平 / 垂直内边距（等同 `padding(horizontal:vertical:)`）
    /// - Parameters:
    ///   - 水平: 左右内边距，单位 pt
    ///   - 垂直: 上下内边距，单位 pt
    @ViewBuilder
    func 内边距(水平: CGFloat, 垂直: CGFloat) -> some View {
        padding(horizontal: 水平, vertical: 垂直)
    }

    /// 在父容器中居中（等同 `centered`）
    @ViewBuilder
    func 居中() -> some View {
        centered()
    }
}

// MARK: 背景、圆角、边框、阴影

public extension View {
    /// 设置背景颜色（等同 `backgroundColor`）
    /// - Parameter 颜色: 背景颜色
    @ViewBuilder
    func 背景颜色(_ 颜色: Color) -> some View {
        backgroundColor(颜色)
    }

    /// 线性渐变背景（等同 `backgroundGradient`）
    /// - Parameters:
    ///   - 颜色: 渐变颜色数组
    ///   - 起点: 渐变起点，默认 `.topLeading`
    ///   - 终点: 渐变终点，默认 `.bottomTrailing`
    @ViewBuilder
    func 渐变背景(_ 颜色: [Color],
                  起点: UnitPoint = .topLeading,
                  终点: UnitPoint = .bottomTrailing) -> some View {
        backgroundGradient(颜色, startPoint: 起点, endPoint: 终点)
    }

    /// 圆角裁剪（等同 `clippedToRoundedRect`）
    /// - Parameter 半径: 圆角半径，单位 pt
    @ViewBuilder
    func 圆角裁剪(_ 半径: CGFloat) -> some View {
        clippedToRoundedRect(半径)
    }

    /// 圆角描边（等同 `overlayBorder`）
    /// - Parameters:
    ///   - 颜色: 边框颜色
    ///   - 宽度: 边框线宽，默认 `1`
    ///   - 圆角半径: 圆角半径，默认 `0`
    @ViewBuilder
    func 圆角描边(颜色: Color, 宽度: CGFloat = 1, 圆角半径: CGFloat = 0) -> some View {
        overlayBorder(color: 颜色, width: 宽度, cornerRadius: 圆角半径)
    }

    /// 轻量阴影（等同 `shadowSm`）
    @ViewBuilder
    func 轻阴影() -> some View { shadowSm() }

    /// 中等阴影（等同 `shadowMd`）
    @ViewBuilder
    func 中阴影() -> some View { shadowMd() }

    /// 强阴影（等同 `shadowLg`）
    @ViewBuilder
    func 强阴影() -> some View { shadowLg() }
}

// MARK: 文字与字体

public extension View {
    /// 设置文字颜色（等同 `textColor`）
    /// - Parameter 颜色: 文字颜色
    @ViewBuilder
    func 文字颜色(_ 颜色: Color) -> some View { textColor(颜色) }

    /// 文字对齐方式（等同 `textAlignment`）
    /// - Parameter 对齐: `.leading` / `.center` / `.trailing`
    @ViewBuilder
    func 文字对齐(_ 对齐: TextAlignment) -> some View { textAlignment(对齐) }

    /// 限制最大行数（等同 `maxLines`）
    /// - Parameter 行数: 最大显示行数
    @ViewBuilder
    func 最大行数(_ 行数: Int) -> some View { maxLines(行数) }

    /// 设置行间距（等同 `textLineSpacing`）
    /// - Parameter 间距: 行间距，单位 pt
    @ViewBuilder
    func 文字行间距(_ 间距: CGFloat) -> some View { textLineSpacing(间距) }

    /// 文字加粗（等同 `boldText`）
    @available(macOS 13.0, *)
    @ViewBuilder
    func 加粗() -> some View { boldText() }

    /// 一站式文字样式（等同 `textStyle`）
    /// - Parameters:
    ///   - 字体: 字体，例如 `.title`、`.headline`
    ///   - 颜色: 文字颜色，默认 `.primary`
    ///   - 字重: 字重，默认 `.regular`
    ///   - 对齐: 对齐方式，默认 `.leading`
    ///   - 间距: 行间距，默认 `0`
    @available(macOS 13.0, *)
    @ViewBuilder
    func 文字样式(字体: Font,
                   颜色: Color = .primary,
                   字重: Font.Weight = .regular,
                   对齐: TextAlignment = .leading,
                   间距: CGFloat = 0) -> some View {
        textStyle(font: 字体, color: 颜色, weight: 字重, alignment: 对齐, spacing: 间距)
    }
}

// MARK: 图片

public extension Image {
    /// 自适应缩放图片（等同 `fitImage`）
    @ViewBuilder
    func 自适应图片() -> some View { fitImage() }

    /// 填充缩放图片（等同 `fillImage`）
    @ViewBuilder
    func 填充图片() -> some View { fillImage() }

    /// 圆形图片（等同 `circleImage`）
    /// - Parameter 尺寸: 圆形直径，单位 pt
    @ViewBuilder
    func 圆形图片(尺寸: CGFloat) -> some View { circleImage(size: 尺寸) }

    /// 圆角图片（等同 `roundedImage`）
    /// - Parameters:
    ///   - 圆角半径: 圆角半径，单位 pt
    ///   - 尺寸: 可选，图片宽高
    @ViewBuilder
    func 圆角图片(圆角半径: CGFloat, 尺寸: CGFloat? = nil) -> some View {
        roundedImage(cornerRadius: 圆角半径, size: 尺寸)
    }
}

// MARK: 交互与动画

public extension View {
    /// 轻点手势（等同 `onTap`）
    /// - Parameter 操作: 点击后执行的操作
    @ViewBuilder
    func 轻点(操作: @escaping () -> Void) -> some View { onTap(perform: 操作) }

    /// 设置不透明度（等同 `viewOpacity`）
    /// - Parameter 值: `0`（全透明）到 `1`（不透明）
    @ViewBuilder
    func 不透明度(_ 值: Double) -> some View { viewOpacity(值) }

    /// 条件隐藏（等同 `hiddenIf`）
    /// - Parameter 是否隐藏: 为 `true` 时隐藏
    @ViewBuilder
    func 条件隐藏(_ 是否隐藏: Bool) -> some View { hiddenIf(是否隐藏) }

    /// 条件执行（等同 `if`）
    /// - Parameters:
    ///   - 条件: 判断条件
    ///   - 变换: 条件为 `true` 时应用的变换
    @ViewBuilder
    func 条件执行<Content: View>(_ 条件: Bool, 变换: (Self) -> Content) -> some View {
        if 条件 { 变换(self) } else { self }
    }

    /// 按压反馈（等同 `pressable`）
    /// - Parameter 缩放: 按压时缩放比例，默认 `0.95`
    func 按压反馈(缩放: CGFloat = 0.95) -> some View { pressable(scale: 缩放) }

    /// 按压反馈按钮样式（等同 `pressableButtonStyle`）
    /// - Parameter 缩放: 按压时缩放比例，默认 `0.95`
    func 按钮按压反馈(缩放: CGFloat = 0.95) -> some View { pressableButtonStyle(scale: 缩放) }
}

// MARK: 复合样式

public extension View {
    /// 卡片样式（等同 `cardStyle`）
    /// - Parameters:
    ///   - 圆角半径: 圆角半径，默认 `16`
    ///   - 内边距: 内边距，默认 `16`
    ///   - 阴影级别: `1` 轻 / `2` 中 / `3` 强，默认 `2`
    @ViewBuilder
    func 卡片样式(圆角半径: CGFloat = 16, 内边距: CGFloat = 16, 阴影级别: Int = 2) -> some View {
        cardStyle(cornerRadius: 圆角半径, padding: 内边距, shadowLevel: 阴影级别)
    }

    /// 徽标样式（等同 `badgeStyle`）
    /// - Parameters:
    ///   - 颜色: 背景色，默认 `.red`
    ///   - 文字颜色: 文字颜色，默认 `.white`
    @ViewBuilder
    func 徽标样式(颜色: Color = .red, 文字颜色: Color = .white) -> some View {
        badgeStyle(color: 颜色, textColor: 文字颜色)
    }
}

// MARK: 动画与过渡

public extension View {
    /// 为视图绑定动画（等同 `animate`）
    /// - Parameters:
    ///   - 曲线: 动画曲线，默认 `.default`
    ///   - 值: 触发动画的状态值
    @ViewBuilder
    func 动画<Value: Equatable>(曲线: Animation = .default, 值: Value) -> some View {
        animate(曲线, value: 值)
    }

    /// 淡入淡出过渡（等同 `fadeTransition`）
    @ViewBuilder
    func 淡入淡出过渡() -> some View { fadeTransition() }

    /// 滑动过渡（等同 `slideTransition`）
    /// - Parameter 方向: 滑入方向，默认 `.trailing`
    @ViewBuilder
    func 滑动过渡(方向: Edge = .trailing) -> some View { slideTransition(edge: 方向) }

    /// 缩放过渡（等同 `scaleTransition`）
    /// - Parameter 比例: 起始缩放比例，默认 `0.9`
    @ViewBuilder
    func 缩放过渡(比例: CGFloat = 0.9) -> some View { scaleTransition(scale: 比例) }

    /// 淡入缩放过渡（等同 `fadeScaleTransition`）
    /// - Parameter 比例: 起始缩放比例，默认 `0.9`
    @ViewBuilder
    func 淡入缩放过渡(比例: CGFloat = 0.9) -> some View { fadeScaleTransition(scale: 比例) }
}

// MARK: 手势

public extension View {
    /// 双击手势（等同 `onDoubleTap`）
    /// - Parameter 操作: 双击后执行的操作
    @ViewBuilder
    func 双击(操作: @escaping () -> Void) -> some View { onDoubleTap(perform: 操作) }

    /// 长按手势（等同 `onLongPress`）
    /// - Parameters:
    ///   - 最短时长: 需要按住的最短秒数，默认 `0.5`
    ///   - 操作: 触发后执行的操作
    @ViewBuilder
    func 长按(最短时长: Double = 0.5, 操作: @escaping () -> Void) -> some View {
        onLongPress(minimumDuration: 最短时长, perform: 操作)
    }

    /// 滑动手势（等同 `onSwipe`）
    /// - Parameters:
    ///   - 上: 上滑回调
    ///   - 下: 下滑回调
    ///   - 左: 左滑回调
    ///   - 右: 右滑回调
    @ViewBuilder
    func 滑动(上: (() -> Void)? = nil,
              下: (() -> Void)? = nil,
              左: (() -> Void)? = nil,
              右: (() -> Void)? = nil) -> some View {
        onSwipe(up: 上, down: 下, left: 左, right: 右)
    }
}

// MARK: 输入框

public extension View {
    /// 圆角输入框样式（等同 `inputStyle`）
    /// - Parameters:
    ///   - 圆角半径: 圆角半径，默认 `8`
    ///   - 内边距: 内边距，默认 `10`
    @ViewBuilder
    func 输入框样式(圆角半径: CGFloat = 8, 内边距: CGFloat = 10) -> some View {
        inputStyle(cornerRadius: 圆角半径, padding: 内边距)
    }
}

// MARK: 按钮样式

public extension View {
    /// 填充按钮样式（等同 `filledButtonStyle`）
    /// - Parameters:
    ///   - 背景: 背景色，默认 `.accentColor`
    ///   - 前景: 文字颜色，默认 `.white`
    ///   - 圆角半径: 圆角半径，默认 `10`
    @ViewBuilder
    func 填充按钮样式(背景: Color = .accentColor,
                       前景: Color = .white,
                       圆角半径: CGFloat = 10) -> some View {
        filledButtonStyle(background: 背景, foreground: 前景, cornerRadius: 圆角半径)
    }
}

// MARK: 列表与滚动

public extension View {
    /// 普通列表样式（等同 `listStylePlain`）
    @ViewBuilder
    func 列表样式普通() -> some View { listStylePlain() }

    /// 内嵌列表样式（等同 `listStyleInset`）
    @ViewBuilder
    func 列表样式内嵌() -> some View { listStyleInset() }

    /// 隐藏列表行分隔线（等同 `listRowSeparatorHidden`）
    @available(macOS 13.0, *)
    @ViewBuilder
    func 隐藏列表分隔线() -> some View { listRowSeparatorHidden() }

    /// 隐藏滚动条（等同 `scrollIndicatorsHidden`）
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    func 隐藏滚动条() -> some View { scrollIndicatorsHidden() }
}

// MARK: 导航与标题

public extension View {
    /// 内联标题（等同 `inlineTitle`）
    @available(macOS 14.0, *)
    @ViewBuilder
    func 内联标题() -> some View { inlineTitle() }

    /// 大标题（等同 `largeTitle`）
    @ViewBuilder
    func 大标题() -> some View { largeTitle() }

    /// 隐藏导航栏（等同 `hideNavigationBar`）
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    func 隐藏导航栏() -> some View { hideNavigationBar() }

    /// 导航栏背景色（等同 `navigationBarBackground`）
    /// - Parameter 颜色: 背景颜色
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    func 导航栏背景(_ 颜色: Color) -> some View { navigationBarBackground(颜色) }
}

// MARK: 选择器

public extension View {
    /// 分段选择器样式（等同 `pickerStyleSegmented`）
    @ViewBuilder
    func 分段选择器() -> some View { pickerStyleSegmented() }

    /// 菜单选择器样式（等同 `pickerStyleMenu`）
    @ViewBuilder
    func 菜单选择器() -> some View { pickerStyleMenu() }

    /// 行内选择器样式（等同 `pickerStyleInline`）
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    func 行内选择器() -> some View { pickerStyleInline() }
}

// MARK: 进度

public extension View {
    /// 线性进度样式（等同 `progressStyleLinear`）
    @ViewBuilder
    func 线性进度() -> some View { progressStyleLinear() }

    /// 圆形进度样式（等同 `progressStyleCircular`）
    @ViewBuilder
    func 圆形进度() -> some View { progressStyleCircular() }
}

// MARK: 弹窗

public extension View {
    /// 弹出底部面板（等同 `presentSheet`）
    /// - Parameters:
    ///   - 是否显示: 控制是否显示的绑定值
    ///   - 关闭时: 面板关闭时执行的操作
    ///   - 内容: 面板内容
    @ViewBuilder
    func 弹出面板<Content: View>(是否显示: Binding<Bool>,
                                 关闭时: (() -> Void)? = nil,
                                 @ViewBuilder 内容: @escaping () -> Content) -> some View {
        presentSheet(isPresented: 是否显示, onDismiss: 关闭时, content: 内容)
    }

    /// 确认提示框（等同 `confirmAlert`）
    /// - Parameters:
    ///   - 标题: 标题文字
    ///   - 提示内容: 提示内容
    ///   - 是否显示: 控制是否显示的绑定值
    ///   - 确定文字: 确定按钮文字，默认「确定」
    ///   - 确认时: 点击确定后执行的操作
    @ViewBuilder
    func 确认提示框(标题: String,
                    提示内容: String? = nil,
                    是否显示: Binding<Bool>,
                    确定文字: String = "确定",
                    确认时: (() -> Void)? = nil) -> some View {
        confirmAlert(title: 标题, message: 提示内容, isPresented: 是否显示,
                     confirmTitle: 确定文字, onConfirm: 确认时)
    }
}
