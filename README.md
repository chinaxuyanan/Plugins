# KitsDemo —— 三库本地演示工程

一个 macOS SwiftUI 可执行工程，用「本地路径依赖」串起同目录下的三个工具库，
把第四轮新增功能放在一个界面里跑起来看效果：

- **SwiftUIProKit**（v0.11.1）：轮播图 `CarouselView` / 倒计时 `CountdownView` / 引导页 `OnboardingView`
- **LogKit**（v0.8.1）：日志采样 `sampled` / 日志导出 `exportLogs` / 崩溃兜底 `installCrashHandler`
- **SystemInfoKit**（v0.8.1）：网络流量统计 `sampleNetworkTraffic` / 磁盘读写速率 `sampleDiskIOTraffic`

## 目录结构

```
KitsDemo/
├── Package.swift                 # 可执行 target，path 依赖 ../SwiftUIProKit、../LogKit、../SystemInfoKit
├── Sources/KitsDemo/
│   ├── KitsDemoApp.swift         # @main App 入口
│   ├── ContentView.swift         # 主界面（顶部分段选择器切换三个分区）
│   ├── DemoUI.swift              # 卡片容器 + 字节/速率格式化工具
│   ├── SwiftUIProKitPanel.swift  # 轮播图 / 倒计时 / 引导页
│   ├── LogKitPanel.swift         # 写日志 / 采样 / 导出 / 崩溃兜底
│   └── SystemInfoKitPanel.swift  # 网络流量 / 磁盘读写 / 系统速览
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
| SwiftUIProKit 组件 | 图标轮播 + 自定义视图轮播（自动切换、分页圆点）；倒计时（圆环进度、暂停/重置、归零回调）；引导页（弹窗内跳过/下一步/开始使用） |
| LogKit 日志 | 查看日志/崩溃文件路径；写 info/warning/error；拖动滑块改全局采样率、批量采样 100 条；一键导出日志（自动在 Finder 中定位）；一键安装崩溃兜底 |
| SystemInfoKit 系统 | 采样网络流量（接口、累计收发、每秒速率）；采样磁盘读写（累计读写、每秒速率）；系统信息速览 |

## 注意

- 网络流量 / 磁盘读写**首次采样**时速率显示「—（首次采样）」，需要再点一次（间隔产生差值）才会出现每秒速率。
- 崩溃兜底只是「安装」处理器，真实崩溃（未捕获异常或致命信号）才会写入 `LogKit-crash.log`。
- 日志文件与崩溃日志的路径在「LogKit 日志」分区顶部直接展示，可选中复制。
