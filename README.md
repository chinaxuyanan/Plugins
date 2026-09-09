# LogKit —— 中文友好的日志打印工具库

> 解决「日志级别混乱、输出格式不统一」的痛点。
> 内置五级日志、统一输出格式，并提供中文命名别名，补全时直接看到中文方法名。

## 特性

- **五级日志**：调试 / 信息 / 警告 / 错误 / 严重，见名知意
- **分级过滤**：设置 `minimumLevel` 自动屏蔽低级别日志
- **统一格式**：`[时间] [级别] [分类] 消息 @ 文件:行`
- **双格式输出**：单行文本（默认）+ 结构化 JSON，便于日志采集 / 机器解析
- **结构化字段**：日志可附加 `fields` 键值对，JSON 输出时成为 `fields` 子对象
- **自定义格式**：`customFormatter` 闭包完全接管每条日志的拼装
- **耗时测量**：`measure` / `计时` 一行代码计时并输出耗时，同步 / 异步皆可
- **异步写文件**：后台串行队列落盘不阻塞主线程，`严重` 日志始终同步落盘防丢失
- **双通道输出**：控制台 + 可选日志文件（按天分文件，可按大小轮转、按数量清理）
- **分类过滤**：白名单 / 黑名单按分类过滤日志
- **中文别名**：`LogKit.调试(...)` 等，与英文成员一一等价
- **纯 Foundation、零依赖**，iOS 15+ / macOS 12+

## 安装

在 Xcode 中：`File → Add Packages...`，粘贴本仓库地址，选择版本即可。

或在 `Package.swift` 中声明依赖：

```swift
dependencies: [
    .package(url: "https://github.com/<你的账号>/LogKit", from: "0.4.0")
]
```

然后在目标中 `import LogKit`。

## 快速开始

```swift
import LogKit

LogKit.minimumLevel = .debug   // 只输出 debug 及以上级别（默认全部）
LogKit.fileOutput = true       // 同时写入日志文件

LogKit.调试("视图加载完成，耗时 \(elapsed) ms")
LogKit.信息("用户登录成功", 分类: "账号")
LogKit.警告("网络请求超时", 分类: "网络")
LogKit.错误("解析失败：\(reason)", 分类: "数据")
LogKit.严重("数据库连接中断", 分类: "存储")

// 耗时测量：执行代码块并自动输出耗时
let 结果 = LogKit.计时("解析数据") { try parser.parse(data) }
let 数据 = try await LogKit.异步计时("拉取用户信息") { try await api.fetchUser(id) }

// 结构化字段（配合 JSON 输出）
LogKit.info("请求完成", fields: ["接口": "/api/user", "状态码": 200])
```

控制台输出示例：

```
[2026-09-09 14:30:22.123] [信息] [账号] 用户登录成功 @ LoginViewModel.swift:42
```

JSON 输出示例（设置 `LogKit.outputFormat = .json`）：

```json
{"time":"2026-09-09 14:30:22.123","level":"信息","levelValue":1,"category":"账号","message":"用户登录成功","file":"LoginViewModel.swift","line":42}
```

异步写文件：默认开启（`asyncWrite = true`），日志在后台串行队列落盘，不阻塞主线程。App 进入后台 / 退出前可调用 `LogKit.flush()`（或 `刷新缓冲()`）确保全部落盘；`严重` 级别日志无论开关始终同步写入。

## 日志级别

| 级别 | 中文名 | 说明 |
| --- | --- | --- |
| `.debug` | 调试 | 开发期排查，最细粒度 |
| `.info` | 信息 | 常规运行信息 |
| `.warning` | 警告 | 需留意，不影响运行 |
| `.error` | 错误 | 功能出错，需处理 |
| `.critical` | 严重 | 致命错误 |

## 配置项

| 配置 | 默认值 | 说明 |
| --- | --- | --- |
| `minimumLevel` | `.debug` | 最低输出级别 |
| `consoleOutput` | `true` | 是否输出到控制台 |
| `fileOutput` | `false` | 是否写入日志文件 |
| `logDirectory` | Application Support/LogKit | 日志文件目录 |
| `dateFormat` | `yyyy-MM-dd HH:mm:ss.SSS` | 时间戳格式 |
| `showLocation` | `true` | 是否显示「文件:行」位置 |
| `maxFileSize` | `0`（不限制） | 单文件大小上限（字节），超出自动归档 |
| `maxLogFiles` | `0`（不清理） | 最多保留的日志文件数，超出删最旧 |
| `enabledCategories` | `nil`（全部） | 分类白名单，只输出名单内分类 |
| `ignoredCategories` | `[]`（空） | 分类黑名单，跳过名单内分类 |
| `outputFormat` | `.text` | 输出格式：`.text` 单行文本 / `.json` 结构化 JSON |
| `customFormatter` | `nil` | 自定义格式闭包 `(LogEntry) -> String`，设置后接管全部格式化 |
| `asyncWrite` | `true` | 是否异步写文件；关闭则同步落盘 |

## 中文命名别名

| 中文别名 | 等同英文成员 |
| --- | --- |
| `LogKit.调试(...)` | `LogKit.debug(...)` |
| `LogKit.信息(...)` | `LogKit.info(...)` |
| `LogKit.警告(...)` | `LogKit.warning(...)` |
| `LogKit.错误(...)` | `LogKit.error(...)` |
| `LogKit.严重(...)` | `LogKit.critical(...)` |
| `LogKit.计时(标签) { ... }` | `LogKit.measure(...)` |
| `LogKit.异步计时(标签) { ... }` | `LogKit.measureAsync(...)` |
| `LogKit.清空日志()` | `LogKit.clearLog()` |
| `LogKit.轮转日志()` | `LogKit.rotateLogFile()` |
| `LogKit.刷新缓冲()` | `LogKit.flush()` |
| `LogKit.输出格式` | `LogKit.outputFormat` |
| `LogKit.异步写入` | `LogKit.asyncWrite` |
| `LogKit.自定义格式` | `LogKit.customFormatter` |

## 更新日志

- **0.4.0**：新增耗时测量（`measure` / `measureAsync` / `计时` / `异步计时`，执行代码块并输出耗时，抛错时记录「失败 · 耗时」）、结构化字段（五级日志方法新增 `fields` 参数，JSON 输出成为 `fields` 子对象，文本输出追加 `[key=value]`）、自定义格式闭包（`customFormatter` / `自定义格式`，接收 `LogEntry` 完全接管日志拼装），均含中文别名。
- **0.3.0**：新增 JSON 结构化输出（`outputFormat = .json`，含时间/级别/级别值/分类/消息/位置字段）与异步写文件（`asyncWrite` 后台串行队列落盘，`flush` / `刷新缓冲` 等待落盘，`严重` 日志始终同步），均含中文别名。
- **0.2.0**：新增文件轮转（`maxFileSize` 按大小归档、`maxLogFiles` 按数量清理、`rotateLogFile` / `轮转日志` 主动轮转）与分类过滤（`enabledCategories` 白名单 / `ignoredCategories` 黑名单）。
- **0.1.0**：首个版本，五级日志、分级过滤、控制台 / 文件双输出、中文命名别名。

## License

MIT
