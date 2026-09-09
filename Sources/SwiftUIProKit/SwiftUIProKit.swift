import SwiftUI

/// SwiftUIProKit —— SwiftUI 属性中文封装工具库
///
/// 解决 SwiftUI 开发中「控件属性太多、不知道用哪个」的痛点：
/// - 将常用控件属性按类别整理、封装成语义化方法；
/// - 每个方法都带有中文文档注释，Xcode 补全 / Quick Help 中可直接看到中文含义；
/// - 提供常用复合样式（卡片、徽标、按压反馈等），一行代码完成常见效果。
///
/// 分类一览：
/// - `View+Layout.swift`      布局与尺寸
/// - `View+Background.swift`  背景、圆角、边框、阴影
/// - `View+Text.swift`        文字与字体
/// - `View+Image.swift`       图片
/// - `View+Interaction.swift` 交互、按压反馈
/// - `View+Animation.swift`   动画与过渡
/// - `View+Gesture.swift`     手势
/// - `View+Input.swift`       输入框
/// - `View+Button.swift`      按钮样式
/// - `View+List.swift`        列表与滚动
/// - `View+Navigation.swift`  导航与标题
/// - `View+Picker.swift`      选择器
/// - `View+Progress.swift`    进度
/// - `View+Sheet.swift`       弹窗
/// - `View+Card.swift`        复合样式
/// - `View+Controls.swift`    控件样式（开关 / 菜单 / 主题色）
/// - `View+Tab.swift`         标签页
/// - `View+Keyboard.swift`    键盘与焦点
/// - `Color+Hex.swift`        颜色工具（十六进制 / 随机色）
/// - `View+ChineseAlias.swift` 中文命名别名
public enum SwiftUIProKit {
    /// 库版本号
    public static let version = "0.5.0"
}
