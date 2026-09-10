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
/// - `View+AdvancedLayout.swift` 布局强化（尺寸 / 等比缩放 / 安全区 / 网格列）
/// - `View+Shape.swift`       形状与裁剪（圆形 / 胶囊 / 部分圆角 / 虚线边框 / 蒙版）
/// - `View+ShadowGradient.swift` 阴影与渐变（自定义阴影 / 发光 / 径向 / 角度渐变）
/// - `View+Lifecycle.swift`   生命周期（出现 / 消失 / 变化 / 订阅 / 异步任务）
/// - `View+Skeleton.swift`    骨架屏（骨架占位 / 扫光）
/// - `View+RefreshSearch.swift` 刷新与搜索（下拉刷新 / 搜索框）
/// - `FlowLayout.swift`       流式布局（标签自动换行，iOS 16 / macOS 13+）
/// - `Haptics.swift`          触觉反馈（冲击 / 选择 / 通知，仅 iOS）
/// - `View+AdvancedAlert.swift` 弹窗进阶（多按钮 / 破坏性确认 / 动作菜单 / 气泡 / 右键菜单）
/// - `View+Grid.swift`        网格（等宽列 / 自适应列 / Grid 容器，部分 iOS 16 / macOS 13+）
/// - `View+Form.swift`        表单与分组（分组卡片 / 表单样式）
/// - `View+Material.swift`    毛玻璃与材质
/// - `View+TextGradient.swift` 文字渐变
/// - `View+Badge.swift`       徽标角标
/// - `View+EmptyState.swift`  空状态视图
/// - `View+Toast.swift`       Toast 轻提示
/// - `LoadingButton.swift`    加载按钮（转圈 + 禁用）
/// - `RatingView.swift`       评分视图（星级，只读 / 可交互）
/// - `CollapsibleView.swift`  可折叠面板（手风琴）
/// - `CarouselView.swift`     轮播图（自动轮播 + 分页圆点）
/// - `CountdownView.swift`    倒计时视图（圆环进度 + 归零回调）
/// - `OnboardingView.swift`   引导页（多页滑动 + 跳过 / 开始使用）
/// - `View+ReadSize.swift`    尺寸读取（`readSize` 监听视图实际尺寸）
/// - `View+Shimmer.swift`     微光扫光效果
/// - `Image+QRCode.swift`     二维码生成（Core Image）
/// - `View+ConfirmationDialog.swift` 确认弹窗
/// - `View+StrokeBorder.swift` 渐变描边（渐变 / 虚线渐变）
/// - `RingProgress.swift`     环形进度（确定进度圆环）
/// - `AnimatedNumber.swift`   滚动数字（数值变化平滑滚动）
/// - `View+Watermark.swift`   水印（平铺倾斜文字）
/// - `View+ChineseAlias.swift` 中文命名别名
public enum SwiftUIProKit {
    /// 库版本号
    public static let version = "0.13.0"
}
