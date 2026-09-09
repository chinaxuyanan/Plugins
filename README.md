# SwiftUIProKit —— SwiftUI 属性中文封装工具库

> 解决 SwiftUI 开发中「控件属性太多、不知道用哪个」的痛点。
> 把常用属性按类别整理、封装成语义化方法，并附上**中文文档注释**，让你在 Xcode 补全 / Quick Help 中直接看到每个属性的中文含义。

## 特性

- **中文文档注释**：每个方法都带中文说明（用途、参数、示例），按住 Option 点按方法即可查看
- **按类别封装**：布局、背景、文字、图片、交互、动画、手势、输入框、按钮、列表、导航、选择器、进度、弹窗、复合样式、控件样式、标签页、键盘与焦点、颜色工具、布局强化、形状与裁剪、阴影与渐变、生命周期，见名知意
- **复合样式**：卡片、徽标、按压反馈等常用效果一行代码搞定
- **纯 SwiftUI、零第三方依赖**：Swift Package 引入即用
- **iOS 15+ / macOS 12+**

## 安装

在 Xcode 中：`File → Add Packages...`，粘贴本仓库地址，选择版本即可。

或在 `Package.swift` 中声明依赖：

```swift
dependencies: [
    .package(url: "https://github.com/<你的账号>/SwiftUIProKit", from: "0.6.0")
]
```

然后在目标中 `import SwiftUIProKit`。

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
| `boldText()` | 文字加粗 |
| `textStyle(font:color:weight:alignment:spacing:)` | 一站式文字样式 |

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
| `inlineTitle()` | 内联标题 |
| `largeTitle()` | 大标题（iOS 专有，macOS 无效果）|
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

## 路线图

- [x] UI 控件属性封装（第一期，本库）
- [x] UI 控件属性封装（第二期：动画 / 手势 / 输入框 / 按钮）
- [x] UI 控件属性封装（第三期：列表 / 导航 / 选择器 / 进度 / 弹窗）
- [ ] 日志打印工具库（LogKit）
- [ ] 系统检测工具库（SystemInfoKit）
- [x] macOS 平台适配（基础版，跨平台编译）
- [ ] 属性速查的 Xcode 代码片段（Snippets）版本

## 更新日志

- **0.6.0**：新增「布局强化」「形状与裁剪」「阴影与渐变」「生命周期」四个类别封装（`frameSize` / `frameMaxWidth` / `frameMaxHeight` / `scaledAspect` / `ignoreSafeArea` / `safeAreaContent` / `fixedToContent` / `clippedContent` 及 `GridItem` 中文列定义、`circleClip` / `capsuleClip` / `roundedCorners` / `circleStroke` / `capsuleStroke` / `dashedBorder` / `maskWith`（含 `RectCorner` / `RoundedCorner`）、`customShadow` / `glow` / `radialBackgroundGradient` / `angularBackgroundGradient`、`didAppear` / `didDisappear` / `didChange` / `didReceive` / `asyncTask`），均含中文别名。
- **0.5.0**：新增「控件样式」「标签页」「键盘与焦点」「颜色工具」四个类别封装（`toggleStyleSwitch` / `toggleStyleButton` / `toggleStyleCheckbox` / `controlTint` / `menuStyleButton`、`tabViewStyleAutomatic` / `tabViewStylePage` / `tabItemLabel`、`dismissKeyboardOnTap` / `keyboardToolbarDone` / `textEditorPlaceholder`、`Color(hex:)` / `Color(hexString:)` / `Color.random()` / `hexString`），均含中文别名。
- **0.4.0**：新增「列表与滚动」「导航与标题」「选择器」「进度」「弹窗」五个类别封装（`listStylePlain` / `listStyleInset` / `listRowSeparatorHidden` / `scrollIndicatorsHidden`、`inlineTitle` / `largeTitle` / `hideNavigationBar` / `navigationBarBackground`、`pickerStyleSegmented` / `pickerStyleMenu` / `pickerStyleInline`、`progressStyleLinear` / `progressStyleCircular`、`presentSheet` / `confirmAlert`），均含中文别名。
- **0.3.0**：新增「动画与过渡」「手势」「输入框」「按钮样式」四个类别封装（`animate` / `fadeTransition` / `slideTransition` / `scaleTransition` / `fadeScaleTransition`、`onDoubleTap` / `onLongPress` / `onSwipe`、`inputStyle`、`filledButtonStyle`），均含中文别名。
- **0.2.0**：`foregroundColor` 全部替换为 `foregroundStyle`（消除 macOS 14+ 弃用警告）；`cardStyle` 背景改用跨平台 `Color.cardBackground`（macOS 使用控件背景色）；新增按钮按压样式 `pressableButtonStyle()` 及中文别名 `按钮按压反馈`。
- **0.1.0**：首个版本，覆盖布局、背景、文字、图片、交互、复合样式六类封装，含中文文档注释与中文命名别名。

## License

MIT
