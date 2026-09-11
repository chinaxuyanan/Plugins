# KitsDemo —— 三库本地演示工程

一个 macOS SwiftUI 可执行工程，用「本地路径依赖」串起同目录下的三个工具库，
把它们的主要功能放在一个界面里跑起来看效果：

- **SwiftUIProKit**（v1.8.0）：轮播图 `CarouselView` / 倒计时 `CountdownView` / 引导页 `OnboardingView` / 文本增强（`ExpandableText` / `HighlightedText` / `TypingText`）/ 热力图日历 `HeatmapCalendar` / 瀑布流 `MasonryGrid` / 日历选择器 `CalendarPicker` / 标签输入 `TagInput` / 饼图 `PieChart` / 折线图 `LineChart` / 柱状图 `BarChart` / 底部抽屉 `BottomSheet` / 浮动标签输入框 `FloatingLabelField` / 图片对比滑块 `BeforeAfterSlider`
- **LogKit**（v1.5.0）：写日志 / 采样 `sampled` / 导出 `exportLogs` / 崩溃兜底 `installCrashHandler` / 反解析 `parseLogFile` / 链路聚合 `groupByTrace` / 合并日志 `mergeLogFiles` / 格式模板 `LogTemplate` / Markdown 报告 `exportMarkdown` / HTML 报告 `exportHTML` / 按消息聚合 `groupByMessage` / 差异导出 `exportSince` / 体积统计 `logStorage`
- **SystemInfoKit**（v1.5.0）：网络流量 `sampleNetworkTraffic` / 磁盘读写 `sampleDiskIOTraffic` / 内存明细 `memoryBreakdown` / 每核 CPU `perCoreCPUUsage` / 电池温度与电源 `batteryTemperature` · `powerAdapter` / 已安装应用 `installedApplications` / 显卡 `gpuInfo` / USB 外设 `usbDevices` / 风扇与温度 `fanSpeeds` · `machineTemperature` / 电池剩余时间 `batteryTimeRemaining`

## 目录结构

```
KitsDemo/
├── Package.swift                 # 可执行 target，path 依赖 ../SwiftUIProKit、../LogKit、../SystemInfoKit
├── Sources/KitsDemo/
│   ├── KitsDemoApp.swift         # @main App 入口
│   ├── ContentView.swift         # 主界面（顶部分段选择器切换三个分区）
│   ├── DemoUI.swift              # 卡片容器 + 字节/速率格式化工具
│   ├── SwiftUIProKitPanel.swift  # 轮播 / 倒计时 / 引导页 / 文本增强 / 热力图 / 瀑布流 / 日历 / 标签 / 饼图 / 折线图 / 柱状图 / 底部抽屉 / 浮动标签 / 图片对比
│   ├── LogKitPanel.swift         # 写日志 / 采样 / 导出 / 崩溃兜底 / 反解析 / 链路聚合 / 合并 / 模板 / Markdown / HTML / 按消息聚合 / 差异导出 / 体积统计
│   └── SystemInfoKitPanel.swift  # 网络流量 / 磁盘读写 / 内存明细 / 每核 CPU / 电池电源 / 已安装应用 / 显卡 / USB / 风扇温度 / 电池剩余时间
└── README.md
```

## 运行方式

**方式一：Xcode**

1. `File → Open…`，选中 `KitsDemo/Package.swift`；
2. 顶部 Scheme 选择 `KitsDemo`（可执行目标）；
3. `⌘R` 运行。

**方式二：终端**

```bash
cd /Users/yanan/Desktop/Xcode_Projects/Plugins/KitsDemo
swift run
```

> 首次运行会解析并编译三个本地依赖库，稍等即可。

## 分区说明

| 分区 | 演示内容 |
| --- | --- |
| SwiftUIProKit 组件 | 图标轮播 + 自定义视图轮播（自动切换、分页圆点）；倒计时（圆环进度、暂停/重置、归零回调）；引导页（弹窗内跳过/下一步/开始使用）；展开收起文本、关键词高亮、打字机文本；热力图日历；瀑布流（不等高多列）；日历选择器（单选 + 选区段）；标签输入；饼图 / 环形占比图；折线图（Y 轴刻度、网格线、X 轴标签）；柱状图（多系列并排、高亮最大值）；底部抽屉（贴底弹出、多档位拖动）；浮动标签输入框（聚焦上浮、错误态）；图片对比滑块（拖动把手改分割） |
| LogKit 日志 | 查看日志/崩溃文件路径；写 info/warning/error；拖动滑块改全局采样率、批量采样 100 条；一键导出日志（自动在 Finder 中定位）；一键安装崩溃兜底；反解析当前日志并统计 / 导出 JSON / 导出摘要；按小时轮转开关；写同链路日志并按 traceId 聚合、合并当前 + 归档日志、用模板格式化、导出 Markdown 报告；导出 HTML 报告（自包含网页）；按消息聚合（相同消息归一组）；导出最近 1 小时的日志（增量）；统计日志体积并清理归档 |
| SystemInfoKit 系统 | 采样网络流量（接口、累计收发、每秒速率）；采样磁盘读写（累计读写、每秒速率）；系统信息速览；电池细分状态；进程占用排行；网卡物理地址；内存明细（活跃/非活跃/联动/压缩）；每核 CPU 使用率；电池温度与电源适配器明细；已安装应用列表；显卡信息（Metal 默认设备）；USB 外设列表；风扇转速与整机温度（SMC）；电池剩余 / 充满剩余时间 |

## 注意

- 网络流量 / 磁盘读写 / 每核 CPU **首次采样**时速率显示「—（首次采样）」，需要再点一次（间隔产生差值）才会出现每秒速率。
- 崩溃兜底只是「安装」处理器，真实崩溃（未捕获异常或致命信号）才会写入 `LogKit-crash.log`。
- 日志文件与崩溃日志的路径在「LogKit 日志」分区顶部直接展示，可选中复制。
- 瀑布流 `MasonryGrid` 与标签输入 `TagInput` 需要 macOS 13+（工程最低 macOS 12），演示代码用 `if #available(macOS 13, *)` 包了一层，低版本上会跳过这两张卡片。
- 显卡 / USB / 风扇 / 整机温度 / 电池剩余时间都只在 macOS 有数据；无风扇机型（如 MacBook Air、部分 Apple Silicon 机型）读不到风扇是正常的。风扇与温度要遍历 SMC，所以放在按钮点击时读取，不做高频刷新。
