# SwiftUIProKit —— SwiftUI 属性中文封装工具库

> 解决 SwiftUI 开发中「控件属性太多、不知道用哪个」的痛点。
> 把常用属性按类别整理、封装成语义化方法，并附上**中文文档注释**，让你在 Xcode 补全 / Quick Help 中直接看到每个属性的中文含义。

## 特性

- **中文文档注释**：每个方法都带中文说明（用途、参数、示例），按住 Option 点按方法即可查看
- **按类别封装**：布局、背景、文字、图片、交互、动画、手势、输入框、按钮、列表、导航、选择器、进度、弹窗、弹窗进阶、复合样式、控件样式、标签页、键盘与焦点、颜色工具、布局强化、形状与裁剪、阴影与渐变、生命周期、骨架屏、刷新与搜索、流式布局、网格、表单与分组、毛玻璃与材质、触觉反馈、文字渐变、徽标角标、空状态视图、Toast 轻提示、尺寸监听、微光扫光、二维码生成、确认弹窗、渐变描边、水印，见名知意
- **复合样式**：卡片、徽标、按压反馈等常用效果一行代码搞定
- **复合组件**：加载按钮 `LoadingButton`、评分视图 `RatingView`、可折叠面板 `CollapsibleView`、轮播图 `CarouselView`、倒计时 `CountdownView`、引导页 `OnboardingView`、环形进度 `RingProgress`、滚动数字 `AnimatedNumber`、远程图片 `RemoteImage`、验证码输入框 `OTPField`、跑马灯 `MarqueeText`、步骤条 `StepsView`、头像与头像组 `Avatar` / `AvatarGroup`、时间轴 `Timeline`、迷你图表 `Sparkline` / `MiniBarChart`、搜索栏 `SearchBar`，一行代码完成常见交互
- **纯 SwiftUI、零第三方依赖**：Swift Package 引入即用
- **iOS 15+ / macOS 12+**

## 安装

本库是 [Plugins](../README.md) monorepo 里的一个包，和 `LogKit`、`SystemInfoKit` 并排放在同一个仓库中。把仓库 clone 到本地，用**本地路径依赖**引入：

```swift
dependencies: [
    .package(path: "../Plugins/SwiftUIProKit")
]
```

然后在目标中 `import SwiftUIProKit`。

> **为什么不是 `.package(url: "...", from: "0.15.0")`？** SwiftPM 要求 `Package.swift` 位于仓库根目录，且不支持带前缀的版本 tag，所以没法从远端直接解析子目录里的这个包（官方 issue：[#5768](https://github.com/swiftlang/swift-package-manager/issues/5768)、[#5780](https://github.com/swiftlang/swift-package-manager/issues/5780)）。如果需要「按版本从远端依赖」，在仓库根目录加一个 `Package.swift` 把三个库收成三个 product 即可，详见 [Plugins/README.md](../README.md)。

## 快速开始

```swift
import SwiftUI
import SwiftUIProKit

struct DemoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("标题")
                .textStyle(font: .title2, color: .blue, weight: .bold)

            Text("这是一段描述文字，超过两行会自动截断……")
                .textColor(.secondary)
                .maxLines(2)
                .textLineSpacing(4)

            Image("avatar")
                .circleImage(size: 64)

            Text("标签")
                .badgeStyle(color: .orange)

            Button("确认") { }
                .fillWidth()
                .cardStyle()
                .pressableButtonStyle()
        }
        .padding(horizontal: 16, vertical: 20)
    }
}
```

## 中文命名别名

除了英文方法，每个封装都提供了中文命名的别名方法。输入 `.` 触发自动补全时，候选列表里直接就能看到中文方法名，见名即选：

```swift
VStack {
    Image(systemName: "star.fill").圆形图片(尺寸: 48)
    Text("标题").文字样式(字体: .title, 颜色: .accentColor, 字重: .bold)
    Text("内容").徽标样式(颜色: .blue)
}
.卡片样式()
```

英文名（如 `circleImage`、`textStyle`）与中文别名（如 `圆形图片`、`文字样式`）一一对应、完全等价，可混用。英文方法保留完整中文文档注释，便于 Option+点击查看详细说明。

主要中文别名速查：

| 中文别名 | 等同英文方法 |
| --- | --- |
| `占满宽度` / `占满高度` / `占满空间` | `fillWidth` / `fillHeight` / `fillSpace` |
| `正方形` / `内边距` / `居中` | `size` / `padding(horizontal:vertical:)` / `centered` |
| `背景颜色` / `渐变背景` / `圆角裁剪` / `圆角描边` | `backgroundColor` / `backgroundGradient` / `clippedToRoundedRect` / `overlayBorder` |
| `轻阴影` / `中阴影` / `强阴影` | `shadowSm` / `shadowMd` / `shadowLg` |
| `文字颜色` / `文字对齐` / `最大行数` / `文字行间距` / `加粗` / `文字样式` | `textColor` / `textAlignment` / `maxLines` / `textLineSpacing` / `boldText` / `textStyle` |
| `自适应图片` / `填充图片` / `圆形图片` / `圆角图片` | `fitImage` / `fillImage` / `circleImage` / `roundedImage` |
| `轻点` / `不透明度` / `条件隐藏` / `条件执行` / `按压反馈` / `按钮按压反馈` | `onTap` / `viewOpacity` / `hiddenIf` / `if` / `pressable` / `pressableButtonStyle` |
| `如果存在` | `ifLet`（可选值存在时执行变换）|
| `加载按钮` / `评分视图` / `可折叠面板` | `LoadingButton` / `RatingView` / `CollapsibleView` |
| `轮播图` / `倒计时视图` / `引导页` / `引导页内容` | `CarouselView` / `CountdownView` / `OnboardingView` / `OnboardingPage` |
| `卡片样式` / `徽标样式` | `cardStyle` / `badgeStyle` |
| `动画` / `淡入淡出过渡` / `滑动过渡` / `缩放过渡` / `淡入缩放过渡` | `animate` / `fadeTransition` / `slideTransition` / `scaleTransition` / `fadeScaleTransition` |
| `双击` / `长按` / `滑动` | `onDoubleTap` / `onLongPress` / `onSwipe` |
| `输入框样式` | `inputStyle` |
| `填充按钮样式` | `filledButtonStyle` |
| `列表样式普通` / `列表样式内嵌` / `隐藏列表分隔线` / `隐藏滚动条` | `listStylePlain` / `listStyleInset` / `listRowSeparatorHidden` / `scrollIndicatorsHidden` |
| `内联标题` / `大标题` / `隐藏导航栏` / `导航栏背景` | `inlineTitle` / `largeTitle` / `hideNavigationBar` / `navigationBarBackground` |
| `分段选择器` / `菜单选择器` / `行内选择器` | `pickerStyleSegmented` / `pickerStyleMenu` / `pickerStyleInline` |
| `线性进度` / `圆形进度` | `progressStyleLinear` / `progressStyleCircular` |
| `弹出面板` / `确认提示框` | `presentSheet` / `confirmAlert` |
| `开关样式` / `开关按钮样式` / `开关复选样式` / `控件主题色` / `菜单按钮样式` | `toggleStyleSwitch` / `toggleStyleButton` / `toggleStyleCheckbox` / `controlTint` / `menuStyleButton` |
| `标签页自动样式` / `标签页分页样式` / `标签项` | `tabViewStyleAutomatic` / `tabViewStylePage` / `tabItemLabel` |
| `点击收起键盘` / `键盘完成按钮` / `文本域占位` | `dismissKeyboardOnTap` / `keyboardToolbarDone` / `textEditorPlaceholder` |
| `随机颜色` / `十六进制字符串` | `Color.random()` / `hexString` |
| `设置宽高` / `最大宽度` / `最大高度` / `等比缩放` / `忽略安全区` / `安全区内容` / `固定内容尺寸` / `裁剪溢出` | `frameSize` / `frameMaxWidth` / `frameMaxHeight` / `scaledAspect` / `ignoreSafeArea` / `safeAreaContent` / `fixedToContent` / `clippedContent` |
| `弹性` / `自适应` / `固定` | `GridItem.flexible` / `GridItem.adaptive` / `GridItem.fixed` |
| `圆形裁剪` / `胶囊裁剪` / `指定圆角` / `圆形描边` / `胶囊描边` / `虚线边框` / `蒙版裁剪` | `circleClip` / `capsuleClip` / `roundedCorners` / `circleStroke` / `capsuleStroke` / `dashedBorder` / `maskWith` |
| `自定义阴影` / `发光` / `径向渐变背景` / `角度渐变背景` | `customShadow` / `glow` / `radialBackgroundGradient` / `angularBackgroundGradient` |
| `出现时` / `消失时` / `变化时` / `订阅时` / `异步任务` | `didAppear` / `didDisappear` / `didChange` / `didReceive` / `asyncTask` |
| `骨架屏` / `扫光` | `skeleton` / `shimmer` |
| `下拉刷新` / `搜索框` | `pullToRefresh` / `searchableText` |
| `流式布局` | `FlowLayout`（iOS 16+ / macOS 13+）|
| `多按钮弹窗` / `破坏性确认` / `动作菜单` / `弹出气泡` / `右键菜单` | `multiAlert` / `destructiveAlert` / `actionDialog` / `showPopover` / `contextualMenu` |
| `等宽网格` / `自适应网格` | `EqualColumnGrid` / `AdaptiveGrid` |
| `网格` / `网格行` | `Grid` / `GridRow`（iOS 16+ / macOS 13+）|
| `分组卡片` | `GroupCard` |
| `表单样式` | `formStyleCustom`（iOS 16+ / macOS 13+）|
| `毛玻璃` / `材质背景` | `frostedGlass` / `materialBackground` |
| `冲击` / `选择` / `通知` / `成功` / `警告` / `错误` | `Haptics.impact` / `selection` / `notification` / `success` / `warning` / `error`（仅 iOS）|
| `文字渐变` | `textGradient` |
| `角标` | `cornerBadge` |
| `空状态视图` | `EmptyStateView`（`.图标/.标题/.描述/.操作文字/.操作`）|
| `轻提示` / `轻提示位置` | `toast` / `ToastPosition` |
| `读取尺寸` | `readSize`（回调视图尺寸变化）|
| `微光` | `shimmer(active:tint:)`（扫光动画，可独立使用）|
| `二维码` / `二维码纠错级别` | `Image.qrCode(...)` / `QRCodeCorrectionLevel` |
| `确认弹窗` | `confirm`（`confirmationDialog` 封装）|
| `渐变描边` / `虚线渐变描边` | `gradientBorder` / `gradientDashedBorder`（渐变 / 虚线描边，支持圆角）|
| `环形进度` / `滚动数字` | `环形进度` / `滚动数字`（复合组件，见下方「复合组件」）|
| `水印` | `watermark`（明文平铺水印，铺满整块区域）|
| `远程图片` / `验证码输入框` | `RemoteImage` / `OTPField`（复合组件，占位 / 重试、分格验证码）|
| `跑马灯` / `跑马灯方向` | `MarqueeText` / `MarqueeDirection`（超宽自动循环滚动）|
| `步骤条` / `步骤条方向` | `StepsView` / `StepsDirection`（横向 / 纵向步骤指示）|
| `头像` / `头像组` / `头像状态` | `Avatar` / `AvatarGroup` / `AvatarStatus`（文字 / 图片 / 远程图，可带在线状态小圆点）|
| `时间轴` / `时间轴条目` | `Timeline` / `TimelineItem`（纵向节点 + 连接线）|
| `迷你折线图` / `迷你柱状图` | `Sparkline` / `MiniBarChart`（无坐标轴的迷你趋势图）|
| `搜索栏` | `SearchBar`（防抖 + 一键清空 + 取消）|

## 属性速查表

### 布局与尺寸

| 方法 | 中文含义 |
| --- | --- |
| `fillWidth(alignment:)` | 占满父视图宽度 |
| `fillHeight(alignment:)` | 占满父视图高度 |
| `fillSpace(alignment:)` | 同时占满父视图宽高 |
| `size(_:)` | 固定为正方形尺寸 |
| `padding(horizontal:vertical:)` | 分别设置水平 / 垂直内边距 |
| `centered()` | 在父容器中居中 |

### 背景 / 圆角 / 边框 / 阴影

| 方法 | 中文含义 |
| --- | --- |
| `backgroundColor(_:)` | 设置背景颜色 |
| `backgroundGradient(_:startPoint:endPoint:)` | 线性渐变背景 |
| `clippedToRoundedRect(_:)` | 圆角裁剪 |
| `overlayBorder(color:width:cornerRadius:)` | 圆角描边 |
| `shadowSm()` | 轻量阴影 |
| `shadowMd()` | 中等阴影 |
| `shadowLg()` | 强阴影 |

### 文字与字体

| 方法 | 中文含义 |
| --- | --- |
| `textColor(_:)` | 设置文字颜色 |
| `textAlignment(_:)` | 文字对齐方式 |
| `maxLines(_:)` | 限制最大行数 |
| `textLineSpacing(_:)` | 设置行间距 |
| `boldText()` | 文字加粗（iOS 16+ / macOS 13+） |
| `textStyle(font:color:weight:alignment:spacing:)` | 一站式文字样式（iOS 16+ / macOS 13+） |

> `boldText` / `textStyle` 内部用的是 `View.fontWeight(_:)`，它自 iOS 16 / macOS 13 才有（`Text.fontWeight(_:)` 是另一个 iOS 13 就有的重载）。这两个方法带有 `@available(iOS 16.0, macOS 13.0, *)`，**别删**——删了 iOS 目标就编不过。iOS 15 上请直接用 `.font(.body.weight(.semibold))`。

### 图片

| 方法 | 中文含义 |
| --- | --- |
| `fitImage()` | 自适应缩放（保持比例） |
| `fillImage()` | 填充缩放（保持比例、裁切） |
| `circleImage(size:)` | 圆形图片（头像） |
| `roundedImage(cornerRadius:size:)` | 圆角图片 |

### 交互与动画

| 方法 | 中文含义 |
| --- | --- |
| `onTap(perform:)` | 轻点手势 |
| `viewOpacity(_:)` | 设置不透明度 |
| `hiddenIf(_:)` | 条件隐藏 |
| `if(_:transform:)` | 条件执行（链式辅助） |
| `pressable(scale:)` | 按压反馈（缩放动画，任意视图） |
| `pressableButtonStyle(scale:)` | 按压反馈（按钮版，ButtonStyle） |

### 动画与过渡

| 方法 | 中文含义 |
| --- | --- |
| `animate(_:value:)` | 为视图绑定动画 |
| `fadeTransition()` | 淡入淡出过渡 |
| `slideTransition(edge:)` | 滑动过渡 |
| `scaleTransition(scale:)` | 缩放过渡 |
| `fadeScaleTransition(scale:)` | 淡入 + 缩放组合过渡 |

### 手势

| 方法 | 中文含义 |
| --- | --- |
| `onDoubleTap(perform:)` | 双击手势 |
| `onLongPress(minimumDuration:perform:)` | 长按手势 |
| `onSwipe(up:down:left:right:)` | 四向滑动手势 |

### 输入框

| 方法 | 中文含义 |
| --- | --- |
| `inputStyle(cornerRadius:padding:)` | 圆角输入框样式 |

### 按钮样式

| 方法 | 中文含义 |
| --- | --- |
| `filledButtonStyle(background:foreground:cornerRadius:)` | 填充按钮样式 |

### 列表与滚动

| 方法 | 中文含义 |
| --- | --- |
| `listStylePlain()` | 普通列表样式 |
| `listStyleInset()` | 内嵌列表样式 |
| `listRowSeparatorHidden()` | 隐藏列表行分隔线（macOS 13+）|
| `scrollIndicatorsHidden()` | 隐藏滚动条（iOS 16+ / macOS 13+）|

### 导航与标题

| 方法 | 中文含义 |
| --- | --- |
| `inlineTitle()` | 内联标题（iOS 17+ / macOS 14+）|
| `largeTitle()` | 大标题（iOS 17+；macOS 专有样式不可用，直接返回原视图，故 macOS 不设版本限制）|
| `hideNavigationBar()` | 隐藏导航栏 / 窗口工具栏（iOS 16+ / macOS 13+）|
| `navigationBarBackground(_:)` | 导航栏 / 工具栏背景色（iOS 16+ / macOS 13+）|

### 选择器

| 方法 | 中文含义 |
| --- | --- |
| `pickerStyleSegmented()` | 分段选择器样式 |
| `pickerStyleMenu()` | 菜单选择器样式 |
| `pickerStyleInline()` | 行内选择器样式（iOS 16+ / macOS 13+）|

### 进度

| 方法 | 中文含义 |
| --- | --- |
| `progressStyleLinear()` | 线性进度样式 |
| `progressStyleCircular()` | 圆形进度样式 |

### 弹窗

| 方法 | 中文含义 |
| --- | --- |
| `presentSheet(isPresented:onDismiss:content:)` | 弹出底部面板 |
| `confirmAlert(title:message:isPresented:confirmTitle:onConfirm:)` | 确认提示框（确定 / 取消）|

### 弹窗进阶

| 方法 | 中文含义 |
| --- | --- |
| `multiAlert(_:message:isPresented:actions:)` | 多按钮弹窗（任意按钮组合）|
| `destructiveAlert(_:message:isPresented:destructiveTitle:onDestructive:cancelTitle:)` | 破坏性操作确认弹窗（红色删除按钮）|
| `actionDialog(_:isPresented:titleVisibility:actions:)` | 动作菜单（`confirmationDialog`）|
| `showPopover(isPresented:arrowEdge:content:)` | 气泡弹窗（`popover`）|
| `contextualMenu(menuItems:)` | 右键 / 长按菜单（`contextMenu`）|

### 网格

| 方法 | 中文含义 |
| --- | --- |
| `EqualColumnGrid(columns:spacing:alignment:content:)` | 等宽网格（指定列数，每列等宽）|
| `AdaptiveGrid(minimumWidth:spacing:alignment:content:)` | 自适应网格（按最小宽度自动算列数）|
| `网格` / `网格行` | `Grid` / `GridRow` 中文别名（iOS 16+ / macOS 13+）|

### 表单与分组

| 方法 | 中文含义 |
| --- | --- |
| `GroupCard(_:content:)` | 带标题的分组卡片（`GroupBox`）|
| `formStyleCustom(_:)` | 表单样式（`formStyle`，iOS 16+ / macOS 13+）|

### 毛玻璃与材质

| 方法 | 中文含义 |
| --- | --- |
| `frostedGlass()` | 毛玻璃背景（`ultraThinMaterial`）|
| `materialBackground(_:)` | 材质背景（`regularMaterial` 等）|

### 复合样式

| 方法 | 中文含义 |
| --- | --- |
| `cardStyle(cornerRadius:padding:shadowLevel:)` | 卡片样式 |
| `badgeStyle(color:textColor:)` | 徽标样式 |

### 控件样式

| 方法 | 中文含义 |
| --- | --- |
| `toggleStyleSwitch()` | 开关样式（系统开关）|
| `toggleStyleButton()` | 开关样式（按钮外观）|
| `toggleStyleCheckbox()` | 开关样式（复选框，仅 macOS）|
| `controlTint(_:)` | 控件主题色（开关 / 滑块 / 步进器 / 进度条）|
| `menuStyleButton()` | 菜单按钮样式（iOS 16+ / macOS 13+）|

### 标签页

| 方法 | 中文含义 |
| --- | --- |
| `tabViewStyleAutomatic()` | 自动标签栏样式 |
| `tabViewStylePage(indexDisplayMode:)` | 分页标签样式（仅 iOS）|
| `tabItemLabel(title:systemImage:)` | 标签项（图标 + 文字）|

### 键盘与焦点

| 方法 | 中文含义 |
| --- | --- |
| `dismissKeyboardOnTap()` | 点击空白处收起键盘（iOS）|
| `keyboardToolbarDone(title:)` | 键盘工具栏「完成」按钮（iOS）|
| `textEditorPlaceholder(_:isEmpty:)` | TextEditor 占位文字 |

### 颜色工具

| 方法 | 中文含义 |
| --- | --- |
| `Color(hex:alpha:)` | 十六进制整数创建颜色 |
| `Color(hexString:)` | 十六进制字符串创建颜色 |
| `Color.random()` | 随机颜色 |
| `hexString` | 颜色转十六进制字符串 |

### 布局强化

| 方法 | 中文含义 |
| --- | --- |
| `frameSize(width:height:alignment:)` | 设置视图宽高 |
| `frameMaxWidth(_:alignment:)` | 设置最大宽度 |
| `frameMaxHeight(_:alignment:)` | 设置最大高度 |
| `scaledAspect(_:contentMode:)` | 等比缩放 |
| `ignoreSafeArea(edges:)` | 忽略安全区 |
| `safeAreaContent(edge:content:)` | 安全区边缘插入内容 |
| `fixedToContent(horizontal:vertical:)` | 固定为内容自身尺寸 |
| `clippedContent()` | 裁剪超出边界的部分 |
| `GridItem.flexible / .adaptive / .fixed` | 网格列定义（弹性 / 自适应 / 固定）|

### 形状与裁剪

| 方法 | 中文含义 |
| --- | --- |
| `circleClip()` | 圆形裁剪 |
| `capsuleClip()` | 胶囊形裁剪 |
| `roundedCorners(_:corners:)` | 指定角圆角（`RectCorner` 组合）|
| `circleStroke(color:lineWidth:)` | 圆形描边 |
| `capsuleStroke(color:lineWidth:)` | 胶囊形描边 |
| `dashedBorder(color:lineWidth:dashLength:cornerRadius:)` | 虚线边框 |
| `maskWith(_:)` | 蒙版裁剪 |

### 阴影与渐变

| 方法 | 中文含义 |
| --- | --- |
| `customShadow(color:radius:x:y:)` | 自定义阴影 |
| `glow(color:radius:)` | 发光效果 |
| `radialBackgroundGradient(_:center:startRadius:endRadius:)` | 径向渐变背景 |
| `angularBackgroundGradient(_:center:angle:)` | 角度渐变背景 |

### 生命周期

| 方法 | 中文含义 |
| --- | --- |
| `didAppear(_:)` | 视图出现时执行 |
| `didDisappear(_:)` | 视图消失时执行 |
| `didChange(of:perform:)` | 值变化时执行 |
| `didReceive(_:perform:)` | 订阅发布者 |
| `asyncTask(priority:_:)` | 异步任务（出现启动 / 消失取消）|

### 骨架屏

| 方法 | 中文含义 |
| --- | --- |
| `skeleton(_:)` | 骨架占位（灰化内容）|
| `shimmer(isActive:baseColor:highlightColor:duration:)` | 扫光动画（配合骨架屏）|

### 刷新与搜索

| 方法 | 中文含义 |
| --- | --- |
| `pullToRefresh(_:)` | 下拉刷新 |
| `searchableText(_:placement:prompt:)` | 搜索框 |

### 流式布局

| 方法 | 中文含义 |
| --- | --- |
| `FlowLayout(spacing:lineSpacing:)` | 标签自动换行容器（iOS 16+ / macOS 13+）|

> 中文名 `流式布局`（等同 `FlowLayout`），用法 `流式布局(间距: 8, 行间距: 8) { ... }` 或零参 `FlowLayout() { ... }`；
> 中文构造器的首参 `间距` 无默认值，以免与英文零参构造冲突（详见更新日志）。

### 触觉反馈

| 方法 | 中文含义 |
| --- | --- |
| `Haptics.impact(_:)` | 冲击触感 |
| `Haptics.selection()` | 选择触感 |
| `Haptics.notification(_:)` | 通知触感 |
| `Haptics.success() / warning() / error()` | 成功 / 警告 / 错误触感（仅 iOS）|

### 文字渐变

| 方法 | 中文含义 |
| --- | --- |
| `textGradient(_:startPoint:endPoint:)` | 文字 / 图标线性渐变（渐变叠加 + 蒙版）|

### 徽标角标

| 方法 | 中文含义 |
| --- | --- |
| `cornerBadge(_:color:textColor:alignment:offset:)` | 在视图角落叠加小圆角徽标（未读数 / NEW 标签）|

### 空状态视图

| 方法 | 中文含义 |
| --- | --- |
| `EmptyStateView(icon:title:message:actionTitle:action:)` | 空状态占位视图（图标 + 标题 + 描述 + 可选按钮）|

### Toast 轻提示

| 方法 | 中文含义 |
| --- | --- |
| `toast(_:position:duration:icon:)` | 顶部 / 底部浮出轻提示，自动消失（`ToastPosition` 位置）|

### 尺寸监听

| 方法 | 中文含义 |
| --- | --- |
| `readSize(onChange:)` | 观察视图尺寸变化（`PreferenceKey` + `GeometryReader`）|

### 微光扫光

| 方法 | 中文含义 |
| --- | --- |
| `shimmer(active:tint:)` | 扫光动画（可独立使用，配合骨架屏）|

### 二维码生成

| 方法 | 中文含义 |
| --- | --- |
| `Image.qrCode(_:scale:correctionLevel:)` | 生成二维码图片（`CIQRCodeGenerator`，纠错级别 `.l/.m/.q/.h`）|

### 确认弹窗

| 方法 | 中文含义 |
| --- | --- |
| `confirm(_:isPresented:message:confirmTitle:role:action:)` | 确认弹窗（`confirmationDialog` 封装，可指定按钮角色）|

### 渐变描边与水印

| 方法 | 中文含义 |
| --- | --- |
| `gradientBorder(_:lineWidth:cornerRadius:startPoint:endPoint:)` | 渐变描边（圆角叠加 `LinearGradient` 描边）|
| `gradientDashedBorder(_:lineWidth:dash:gap:cornerRadius:...)` | 虚线渐变描边（渐变 + 虚线样式）|
| `watermark(_:color:font:spacing:angle:)` | 明文平铺水印（自动铺满视图，不拦截点击）|

### 条件修饰符

| 方法 | 中文含义 |
| --- | --- |
| `if(_:transform:)` | 条件为真时执行变换（链式辅助）|
| `ifLet(_:transform:)` | 可选值存在时执行变换 |

### 复合组件

| 组件 | 中文含义 |
| --- | --- |
| `LoadingButton(_:isLoading:icon:action:)` | 加载按钮（加载中转圈 + 禁用）|
| `RatingView(rating:maximum:...)` | 星级评分视图（只读 / `Binding` / 闭包可交互，支持半星）|
| `CollapsibleView(_:icon:isExpanded:content:)` | 可折叠面板（手风琴）|
| `CarouselView(systemImages:interval:height:showsIndicators:)` / `CarouselView(views:...)` | 轮播图（自动轮播 + 分页圆点）|
| `CountdownView(seconds:font:showsProgress:tint:paused:onFinish:)` | 倒计时视图（圆环进度 + 暂停 / 归零回调）|
| `OnboardingView(pages:...:onSkip:onFinish:)` | 引导页（多页滑动 + 跳过 / 开始使用）|
| `RingProgress(value:tint:trackColor:lineWidth:size:showsLabel:labelFont:)` | 环形进度（圆环 + 可选百分比标签，值自动钳制到 0~1）|
| `AnimatedNumber(value:font:tint:decimals:prefix:suffix:)` | 滚动数字（数值变化时平滑滚动到目标值）|
| `RemoteImage(url:cornerRadius:size:contentMode:showsRetry:)` / `RemoteImage(url:...:placeholder:failure:)` | 远程图片（`AsyncImage` 封装：加载占位 + 失败点击重试 + 圆角 / 固定尺寸，可自定义占位与失败视图）|
| `OTPField(code:length:boxSize:spacing:cornerRadius:onComplete:)` | 验证码输入框（分格显示、只收数字、输满回调；支持粘贴整段与 iOS 短信验证码自动填充）|
| `MarqueeText(_:font:tint:speed:gap:direction:isActive:)` | 跑马灯文字（超出容器宽度才滚动，速度 / 间隔 / 方向可调，可选暂停）|
| `StepsView(steps:current:tint:inactiveColor:direction:showsIndex:circleSize:)` | 步骤条（已完成打勾 / 当前高亮，横向或纵向排布）|
| `Avatar(_:size:tint:showsBorder:borderColor:status:)` / `Avatar(image:...)` / `Avatar(url:...)` | 头像（文字占位自动取首字、同名同色 / 本地图片 / 远程图片，可加描边与右下角在线状态）|
| `AvatarGroup(avatars:size:overlap:maxVisible:separatorColor:overflowTint:)` | 头像组（重叠排列，超出部分折叠成「+N」气泡）|
| `Timeline(items:tint:inactiveColor:dotSize:lineWidth:showsIcons:spacing:)` | 时间轴（纵向节点 + 连接线，节点含标题 / 详情 / 图标 / 是否已完成）|
| `Sparkline(values:tint:lineWidth:height:showsArea:showsDots:)` | 迷你折线图（无坐标轴，按自身最值归一化）|
| `MiniBarChart(values:tint:height:spacing:cornerRadius:highlightsMax:)` | 迷你柱状图（按最大值比例算柱高，可高亮最大值）|
| `SearchBar(text:placeholder:showsCancel:cancelTitle:debounceInterval:tint:onSubmit:onDebounce:)` | 搜索栏（放大镜 + 一键清空 + 取消，内置防抖 `Task`）|

> 中文构造器（如 `跑马灯(文字:速度:方向:)`、`加载按钮(标题:加载中:动作:)`、`可折叠面板(标题:展开:内容:)`）的**首个参数一律带中文标签**，与英文 `init` 的无标签首参区分开，避免 Swift 报 `ambiguous use of 'init'`。英文写法仍可省略首参标签（`MarqueeText("公告")`、`LoadingButton("提交") { }`）。

## 路线图

- [x] UI 控件属性封装（第一期，本库）
- [x] UI 控件属性封装（第二期：动画 / 手势 / 输入框 / 按钮）
- [x] UI 控件属性封装（第三期：列表 / 导航 / 选择器 / 进度 / 弹窗）
- [x] 日志打印工具库（LogKit）
- [x] 系统检测工具库（SystemInfoKit）
- [x] macOS 平台适配（基础版，跨平台编译）
- [x] 属性速查的 Xcode 代码片段（Snippets）版本

## 更新日志

- **0.15.0**：新增四个复合组件——头像 `Avatar` / `头像`（三种内容来源：文字占位（中文取前两字、英文取首字母，底色按姓名稳定派生、同名同色）、本地图片、远程图片（内部转发 `RemoteImage`），可选描边与右下角在线状态小圆点 `AvatarStatus` / `头像状态`）与头像组 `AvatarGroup` / `头像组`（重叠排列 + 超出折叠成「+N」气泡）、时间轴 `Timeline` / `时间轴`（纵向节点 + 连接线，节点 `TimelineItem` / `时间轴条目` 含标题 / 详情 / 图标 / 是否已完成；连接线高度用 `readSize` 量出内容实际高度后再补足，标题换行也不断线）、迷你图表（迷你折线图 `Sparkline` / `迷你折线图`、迷你柱状图 `MiniBarChart` / `迷你柱状图`，数值按自身最小 / 最大值归一化，空数组 / 单值 / 全相等都不除零、不跳顶）、搜索栏 `SearchBar` / `搜索栏`（放大镜图标 + 一键清空 + 可选取消，内置 `Task` + `Task.sleep` 防抖，连续输入只在停顿后回调一次；`debounceInterval` 传 `0` 即退化为即时回调），均含中文别名与文档注释并补测试。另修复 `FlowLayout` / `流式布局` 中文构造器的「歧义调用」隐患：其首参 `间距` 改为无默认值，否则 `FlowLayout()`（以及 `FlowLayout() { ... }`）会与英文 `init(spacing:lineSpacing:)`（参数全有默认值）冲突、编译报 `ambiguous use of 'init'`。

- **0.14.0**：新增四个复合组件——远程图片 `RemoteImage` / `远程图片`（`AsyncImage` 封装：加载占位、失败点击重试、圆角与固定尺寸，可用 `@ViewBuilder` 自定义占位 / 失败视图）、验证码输入框 `OTPField` / `验证码输入框`（分格显示、只保留数字、输满 `onComplete` 回调，底层是 1×1 透明 `TextField`，粘贴整段验证码与 iOS 短信自动填充都可用）、跑马灯 `MarqueeText` / `跑马灯`（用 `readSize` 量出文字与容器尺寸，只有超宽才滚动；速度 / 间隔 / 方向可调，两份文字首尾相接实现无缝循环）、步骤条 `StepsView` / `步骤条`（已完成打勾、当前高亮、未完成置灰，横向与纵向两种排布），均含中文别名与文档注释并补测试。另修一处重载歧义：`MarqueeText` / `LoadingButton` / `CollapsibleView` 的中文构造器首参改为带标签（`文字:` / `标题:`）——此前英文与中文 `init` 的首参都省略标签，`跑马灯("x")` 这类调用会因两个重载无法区分而报 `ambiguous use of 'init'`；英文写法不变（`MarqueeText("x")`、`LoadingButton("x") { }` 仍可省略标签）。

- **0.13.1**：修复编译告警——`pullToRefresh` / `下拉刷新` 的参数由 `@escaping () async -> Void` 改为 `@escaping @Sendable () async -> Void`，与 SwiftUI `refreshable(action:)` 要求的 `@Sendable` 契约对齐（此前转发时报 `passing non-Sendable parameter 'action' to function expecting a '@Sendable' closure`）。与既有的 `asyncTask` / `异步任务` 写法保持一致，调用方式不变。

- **0.13.0**：新增「渐变描边」「水印」两个类别封装（`gradientBorder` / `渐变描边`（`LinearGradient` 圆角描边，可指定起止方向）、`gradientDashedBorder` / `虚线渐变描边`（渐变 + 虚线）、`watermark` / `水印`（明文平铺、自动铺满、不拦截点击）），新增复合组件环形进度 `RingProgress` / `环形进度`（圆环 + 可选百分比标签，值自动钳制到 `0~1`）与滚动数字 `AnimatedNumber` / `滚动数字`（基于 `Animatable` 平滑滚动，支持前后缀与小数位），均含中文别名与文档注释并补单元测试。

- **0.12.0**：新增「尺寸监听」「微光扫光」「二维码生成」「确认弹窗」四个类别封装（`readSize` / `读取尺寸`（`PreferenceKey` + `GeometryReader` 观察视图尺寸）、`shimmer(active:tint:)` / `微光`（可独立使用的扫光动画）、`Image.qrCode(...)` / `二维码`（含 `QRCodeCorrectionLevel` / `二维码纠错级别` 纠错级别，基于 `CIQRCodeGenerator`）、`confirm` / `确认弹窗`（`confirmationDialog` 封装，可指定 `ButtonRole`）），均含中文别名与文档注释。

- **0.11.1**：修复 macOS 编译错误——轮播图 `CarouselView` 与引导页 `OnboardingView` 中的 `.tabViewStyle(.page(indexDisplayMode:))` 为 iOS 专有，在 macOS 上不可用。现按平台分流：iOS 保持 `TabView(.page)` 左右滑动，macOS 改用交叉淡入淡出切换当前页。

- **0.11.0**：新增复合组件「轮播图 `CarouselView` / `轮播图`（自动轮播 + 分页圆点，SF Symbol 或任意视图）、倒计时视图 `CountdownView` / `倒计时视图`（圆环进度 + 暂停 / 归零回调）、引导页 `OnboardingView` / `引导页`（多页滑动 + 跳过 / 开始使用，含 `OnboardingPage` / `引导页内容`）」，均含中文别名与文档注释。

- **0.10.0**：新增条件修饰符 `ifLet` / `如果存在`（可选值存在时执行变换，补齐原有 `if` / `条件执行`）、加载按钮 `LoadingButton` / `加载按钮`（加载中转圈 + 禁用）、评分视图 `RatingView` / `评分视图`（只读 / `Binding` / 闭包三种可交互方式，支持半星）、可折叠面板 `CollapsibleView` / `可折叠面板`（手风琴），均含中文别名与文档注释。

- **0.9.0**：新增「文字渐变」「徽标角标」「空状态视图」「Toast 轻提示」四个类别封装（`textGradient` / `文字渐变`、`cornerBadge` / `角标`、`EmptyStateView` / `空状态视图`（图标 + 标题 + 描述 + 可选操作按钮）、`toast` / `轻提示`（含 `ToastPosition` / `轻提示位置`，顶部 / 底部自动消失）），均含中文别名。

- **0.8.0**：新增「弹窗进阶」「网格」「表单与分组」「毛玻璃与材质」四个类别封装（`multiAlert` / `destructiveAlert` / `actionDialog` / `showPopover` / `contextualMenu`、`EqualColumnGrid` / `AdaptiveGrid`（含 `Grid` / `GridRow` 中文别名，iOS 16+ / macOS 13+）、`GroupCard` / `formStyleCustom`（iOS 16+ / macOS 13+）、`frostedGlass` / `materialBackground`），均含中文别名。

- **0.7.0**：新增「骨架屏」「刷新与搜索」「流式布局」「触觉反馈」四个类别封装（`skeleton` / `shimmer`、`pullToRefresh` / `searchableText`、`FlowLayout`（`Layout` 协议标签自动换行，iOS 16+ / macOS 13+）、`Haptics`（`impact` / `selection` / `notification` / `success` / `warning` / `error`，仅 iOS）），均含中文别名。

- **0.6.0**：新增「布局强化」「形状与裁剪」「阴影与渐变」「生命周期」四个类别封装（`frameSize` / `frameMaxWidth` / `frameMaxHeight` / `scaledAspect` / `ignoreSafeArea` / `safeAreaContent` / `fixedToContent` / `clippedContent` 及 `GridItem` 中文列定义、`circleClip` / `capsuleClip` / `roundedCorners` / `circleStroke` / `capsuleStroke` / `dashedBorder` / `maskWith`（含 `RectCorner` / `RoundedCorner`）、`customShadow` / `glow` / `radialBackgroundGradient` / `angularBackgroundGradient`、`didAppear` / `didDisappear` / `didChange` / `didReceive` / `asyncTask`），均含中文别名。
- **0.5.0**：新增「控件样式」「标签页」「键盘与焦点」「颜色工具」四个类别封装（`toggleStyleSwitch` / `toggleStyleButton` / `toggleStyleCheckbox` / `controlTint` / `menuStyleButton`、`tabViewStyleAutomatic` / `tabViewStylePage` / `tabItemLabel`、`dismissKeyboardOnTap` / `keyboardToolbarDone` / `textEditorPlaceholder`、`Color(hex:)` / `Color(hexString:)` / `Color.random()` / `hexString`），均含中文别名。
- **0.4.0**：新增「列表与滚动」「导航与标题」「选择器」「进度」「弹窗」五个类别封装（`listStylePlain` / `listStyleInset` / `listRowSeparatorHidden` / `scrollIndicatorsHidden`、`inlineTitle` / `largeTitle` / `hideNavigationBar` / `navigationBarBackground`、`pickerStyleSegmented` / `pickerStyleMenu` / `pickerStyleInline`、`progressStyleLinear` / `progressStyleCircular`、`presentSheet` / `confirmAlert`），均含中文别名。
- **0.3.0**：新增「动画与过渡」「手势」「输入框」「按钮样式」四个类别封装（`animate` / `fadeTransition` / `slideTransition` / `scaleTransition` / `fadeScaleTransition`、`onDoubleTap` / `onLongPress` / `onSwipe`、`inputStyle`、`filledButtonStyle`），均含中文别名。
- **0.2.0**：`foregroundColor` 全部替换为 `foregroundStyle`（消除 macOS 14+ 弃用警告）；`cardStyle` 背景改用跨平台 `Color.cardBackground`（macOS 使用控件背景色）；新增按钮按压样式 `pressableButtonStyle()` 及中文别名 `按钮按压反馈`。
- **0.1.0**：首个版本，覆盖布局、背景、文字、图片、交互、复合样式六类封装，含中文文档注释与中文命名别名。

## License

MIT
