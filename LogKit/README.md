# LogKit —— 中文友好的日志打印工具库

[![CI](https://github.com/chinaxuyanan/Plugins/actions/workflows/ci.yml/badge.svg?branch=main&label=Plugins%20CI)](https://github.com/chinaxuyanan/Plugins/actions/workflows/ci.yml)

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
- **作用域日志器**：`ScopedLogger` 绑定默认分类，分模块各持一个，实例方法免传分类，可派生 `child` 子分类
- **性能计数器**：`PerformanceCounter` 累计调用次数 / 总耗时 / 平均 / 最大 / 最小，按需 `report()` 汇总不刷屏
- **系统日志桥接**：`OSLogger` 封装 `os.Logger`，日志直达 Console.app（子系统 / 分类 / 隐私等级）
- **追踪 ID**：`traceId` 全局 / 作用域日志器两级，串联一次请求的全部日志（JSON 输出含 `traceId` 字段）
- **自适应级别**：默认最低级别随构建环境自适应（DEBUG `.debug` 全输出 / RELEASE `.warning` 只输出警告及以上）
- **级别计数**：`totalCount(by:)` / `totalCount()` 统计各级别输出条数，`resetCounts()` 清零
- **异步写文件**：后台串行队列落盘不阻塞主线程，`严重` 日志始终同步落盘防丢失
- **双通道输出**：控制台 + 可选日志文件（按天分文件，可按大小轮转、按数量清理）
- **分类过滤**：白名单 / 黑名单按分类过滤日志
- **日志限流**：`throttled` / `限流日志` 同一键在时间窗口内只输出一次，抑制高频刷屏
- **敏感信息脱敏**：按字段名关键词自动把 `password` / `token` 等值替换为 `***`，可关可配
- **终端彩色输出**：`coloredConsoleOutput` 开启后控制台文本按级别着色（仅控制台，不写入文件）
- **日志检索**：`search` / `searchAllFiles` 按关键字搜索当前 / 全部日志文件
- **日志采样**：`sampled` / `采样日志` 按概率随机输出，高频日志按比例降噪（被丢弃时不构造消息，惰性）
- **日志导出**：`exportLogs` / `导出日志` 复制当前日志文件到临时目录，直接交给系统分享面板
- **崩溃兜底**：`installCrashHandler` / `安装崩溃处理` 捕获未捕获异常与常见致命信号，写入崩溃日志文件
- **日志回调**：`onLog` / `日志回调` 钩子，每条日志输出后回调完整 `LogEntry`（含时间 / 级别 / 分类 / 消息 / 字段等）
- **尾部读取**：`tail` / `尾部读取` 读取当前日志文件末尾若干行，适合展示「最近日志」面板
- **归档列表**：`archivedLogFiles` / `归档日志列表` 列出已归档的日志文件（按时间倒序）
- **输出预判**：`isEnabled(level:category:)` / `是否输出(级别:分类:)` 提前判断某条日志是否会被输出，避免无谓的消息构造
- **作用域追踪**：`withTrace` / `追踪执行`（含 `withTraceAsync` / `异步追踪执行`）临时设置 `traceId`，执行完自动恢复，串联一次请求的全部日志
- **单条序列化**：`LogEntry.jsonObject` / `jsonString`（中文别名 `JSON字典` / `JSON字符串`）把任意日志条目转成结构化字典 / JSON 字符串，便于自定义上报
- **自定义输出去向**：`addSink` / `添加输出` 在控制台 / 文件之外再加第三方接收者（上报服务端、自建日志面板等），可注册多个、按 `removeSink` / `清空输出` 移除，线程安全
- **按天数清理**：`maxLogAgeDays` / `日志保留天数` 自动删除超过 N 天的日志文件，可与 `maxLogFiles` 叠加使用
- **CSV 导出**：`exportCSV` / `导出CSV` 把日志条目导出成 CSV（`fields` 自动展开成独立列，带 UTF-8 BOM，Excel 打开中文不乱码），`csvString(from:)` / `CSV字符串(条目:)` 只取文本
- **时区配置**：`timeZone` / `时区` 统一时间戳与日志文件名的时区（如都按 UTC 记录）
- **条目过滤**：`LogFilter` / `日志过滤条件` 按级别 / 分类 / 关键字 / 时间段 / 追踪 ID 组合筛选日志条目，可筛文件读出的行，也可筛内存里的最近日志
- **内存检索**：`maxRecentEntries` / `最近保留条数` 把最近 N 条日志留在内存，`recentEntries` / `最近日志` 取用、`filteredRecentEntries` / `过滤最近日志` 直接按条件筛，无需读文件
- **统计摘要**：`LogSummary` / `日志摘要` 汇总条数 / 各级别条数 / 错误率 / 时间跨度 / 分类排行，`text()` 直接产出中文摘要文本
- **压缩归档导出**：`exportArchive` / `导出压缩包` 把当前日志 + 崩溃日志 + 历史归档一次打包成 zip（纯 Foundation 手写 ZIP，零依赖）
- **按天自动轮转**：`dailyRotation` / `按天轮转` 开启后，跨天写入时自动把前一天的按天日志文件归档改名
- **按小时自动轮转**：`hourlyRotation` / `按小时轮转` 同上的小时级版本，文件名形如 `LogKit-yyyy-MM-dd-HH.log`，适合高频日志或长跑压测
- **JSON 导出**：`exportJSON` / `导出JSON`（配 `jsonString(from:prettyPrinted:)` / `JSON字符串(条目:美化:)`）把一批日志条目导出成 JSON 数组文件，键序稳定、可美化，交给采集 / 分析工具
- **日志反解析**：`parseLogFile` / `日志反解析`（含单行 `parseLogLine` / `解析日志行`）把 `.text` 格式日志文本读回 `LogEntry`，便于导入既有日志做过滤 / 摘要 / 再导出
- **摘要导出**：`exportSummary` / `导出摘要` 把 `LogSummary`（或直接一批条目）写成中文摘要文本文件，随问题反馈一起提交
- **链路聚合**：`groupByTrace` / `按链路聚合` 按 `traceId` 把日志分组，还原一次请求的完整链路（组内按时间排序，无 traceId 的归到「未标记」）
- **合并日志文件**：`mergeLogFiles` / `合并日志` 把当前日志与全部归档一起读出，按时间归并成一个完整日志流
- **格式模板**：`LogTemplate` / `日志模板` 用 `"{级别} | {分类} | {消息}"` 这样的占位符接管行格式，`.formatter` 可直接赋给 `customFormatter`
- **Markdown 报告**：`markdownString` / `Markdown报告`（导出文件 `exportMarkdown` / `导出Markdown`）把摘要写成 Markdown 表格报告，直接粘进 issue / 文档
- **HTML 报告**：`htmlString` / `HTML报告`（导出文件 `exportHTML` / `导出HTML`）把摘要写成自包含网页（样式内联、零外部资源），`&` `<` `>` `"` `'` 自动转义，浏览器直接打开
- **按消息聚合**：`groupByMessage` / `按消息聚合` 把相同消息的日志归成一组（`MessageGroup` / `消息聚合组`），给出次数 / 最高级别 / 涉及分类 / 最早最晚时间，看清「哪句话刷得最多」
- **差异导出**：`exportSince` / `导出增量` 只导出某时刻（或某条日志）之后的日志，配合 `entries(since:in:)` / `增量日志` 做增量备份 / 增量提报
- **体积统计与清理**：`logStorage` / `日志体积`（`LogStorage` / `日志体积统计`）逐个量出日志文件大小并汇总，`clearArchivedLogs` / `清理归档日志` 一键删归档（`humanSize` / `人性化大小` 转可读大小）
- **中文别名**：`LogKit.调试(...)` 等，与英文成员一一等价
- **纯 Foundation、零依赖**，iOS 15+ / macOS 12+

## 安装

本库是 [Plugins](../README.md) monorepo 里的一个包，和 `SwiftUIProKit`、`SystemInfoKit` 并排放在同一个仓库中。把仓库 clone 到本地，用**本地路径依赖**引入：

```swift
dependencies: [
    .package(path: "../Plugins/LogKit")
]
```

然后在目标中 `import LogKit`。

> **为什么不是 `.package(url: "...", from: "1.5.0")`？** SwiftPM 要求 `Package.swift` 位于仓库根目录，且不支持带前缀的版本 tag，所以没法从远端直接解析子目录里的这个包（官方 issue：[#5768](https://github.com/swiftlang/swift-package-manager/issues/5768)、[#5780](https://github.com/swiftlang/swift-package-manager/issues/5780)）。如果需要「按版本从远端依赖」，在仓库根目录加一个 `Package.swift` 把三个库收成三个 product 即可，详见 [Plugins/README.md](../README.md)。

## 快速开始

```swift
import LogKit

LogKit.minimumLevel = .debug   // 手动指定最低级别；不设置时默认随构建环境自适应
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
| `minimumLevel` | 自适应（DEBUG `.debug` / RELEASE `.warning`）| 最低输出级别 |
| `adaptiveMinimumLevel` | — | 环境自适应的默认最低级别（只读，初始化时套用）|
| `traceId` | `nil` | 全局追踪 ID，后续每条日志都附带（JSON 输出 `traceId` 字段）|
| `consoleOutput` | `true` | 是否输出到控制台 |
| `fileOutput` | `false` | 是否写入日志文件 |
| `logDirectory` | Application Support/LogKit | 日志文件目录 |
| `dateFormat` | `yyyy-MM-dd HH:mm:ss.SSS` | 时间戳格式 |
| `timeZone` | `.current` | 时间戳与日志文件名日期所用的时区（如设为 `.gmt` 统一按 UTC 记录）|
| `showLocation` | `true` | 是否显示「文件:行」位置 |
| `maxFileSize` | `0`（不限制） | 单文件大小上限（字节），超出自动归档 |
| `maxLogFiles` | `0`（不清理） | 最多保留的日志文件数，超出删最旧 |
| `maxLogAgeDays` | `0`（不清理） | 日志文件最长保留天数，超出删最旧（按修改时间，可与其他清理项叠加）|
| `dailyRotation` | `false` | 是否按天自动轮转：跨天写入时把前一天的按天日志文件归档改名 |
| `hourlyRotation` | `false` | 是否按小时自动轮转：跨小时写入时把上一小时的按小时日志文件归档改名（文件名形如 `LogKit-yyyy-MM-dd-HH.log`）|
| `maxRecentEntries` | `0`（不保留） | 内存中保留的最近日志条数上限，大于 `0` 时才缓存（供过滤 / 摘要使用）|
| `enabledCategories` | `nil`（全部） | 分类白名单，只输出名单内分类 |
| `ignoredCategories` | `[]`（空） | 分类黑名单，跳过名单内分类 |
| `outputFormat` | `.text` | 输出格式：`.text` 单行文本 / `.json` 结构化 JSON |
| `customFormatter` | `nil` | 自定义格式闭包 `(LogEntry) -> String`，设置后接管全部格式化 |
| `asyncWrite` | `true` | 是否异步写文件；关闭则同步落盘 |
| `redactSensitiveData` | `true` | 是否对敏感字段自动脱敏 |
| `sensitiveFieldKeywords` | `["password", "token", ...]` | 敏感字段名关键词（不区分大小写，包含即命中）|
| `coloredConsoleOutput` | `false` | 控制台文本是否按级别着色（仅 `.text` 输出、仅控制台）|
| `samplingRate` | `0.1` | 采样日志的默认输出概率（`0.0` ~ `1.0`）|
| `onLog` | `nil` | 日志回调钩子 `((LogEntry) -> Void)?`，每条日志输出后触发 |

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
| `LogKit.追踪ID` | `LogKit.traceId` |
| `LogKit.自适应最低级别` | `LogKit.adaptiveMinimumLevel` |
| `LogKit.限流日志(...)` / `LogKit.重置限流()` | `LogKit.throttled(...)` / `LogKit.resetThrottle()` |
| `LogKit.脱敏(字段)` | `LogKit.redact(...)` |
| `LogKit.脱敏敏感字段` / `LogKit.敏感字段关键词` | `LogKit.redactSensitiveData` / `LogKit.sensitiveFieldKeywords` |
| `LogKit.彩色控制台` | `LogKit.coloredConsoleOutput` |
| `LogKit.检索日志(关键字)` / `LogKit.检索全部日志(关键字)` | `LogKit.search(containing:)` / `LogKit.searchAllFiles(containing:)` |
| `LogKit.采样日志(...)` / `LogKit.采样率` | `LogKit.sampled(...)` / `LogKit.samplingRate` |
| `LogKit.导出日志()` | `LogKit.exportLogs()` |
| `LogKit.安装崩溃处理()` / `LogKit.崩溃日志路径` | `LogKit.installCrashHandler()` / `LogKit.crashLogFileURL` |
| `LogKit.尾部读取(行数)` / `LogKit.归档日志列表` / `LogKit.日志回调` | `LogKit.tail(_:)` / `LogKit.archivedLogFiles` / `LogKit.onLog` |
| `LogKit.级别计数(级别)` / `LogKit.日志总数()` / `LogKit.重置计数()` | `LogKit.totalCount(by:)` / `LogKit.totalCount()` / `LogKit.resetCounts()` |
| `LogKit.是否输出(级别:分类:)` | `LogKit.isEnabled(level:category:)` |
| `LogKit.追踪执行(追踪ID) { ... }` / `LogKit.异步追踪执行(追踪ID) { ... }` | `LogKit.withTrace(_:_:)` / `LogKit.withTraceAsync(_:_:)` |
| `LogKit.添加输出 { ... }` / `LogKit.移除输出(标识)` / `LogKit.清空输出()` / `LogKit.输出数量` | `LogKit.addSink(_:)` / `LogKit.removeSink(_:)` / `LogKit.removeAllSinks()` / `LogKit.sinkCount` |
| `LogKit.日志保留天数` / `LogKit.时区` | `LogKit.maxLogAgeDays` / `LogKit.timeZone` |
| `LogKit.按天轮转` / `LogKit.最近保留条数` | `LogKit.dailyRotation` / `LogKit.maxRecentEntries` |
| `LogKit.按小时轮转` | `LogKit.hourlyRotation` |
| `LogKit.JSON字符串(条目:美化:)` / `LogKit.导出JSON(条目:文件名:美化:)` | `LogKit.jsonString(from:prettyPrinted:)` / `LogKit.exportJSON(_:fileName:prettyPrinted:)` |
| `LogKit.解析日志行(行)` / `LogKit.日志反解析(全文)` / `LogKit.日志反解析(文件:)` | `LogKit.parseLogLine(_:)` / `LogKit.parseLogFile(_:)` / `LogKit.parseLogFile(at:)` |
| `LogKit.导出摘要(摘要:列出分类数:文件名:)` / `LogKit.导出摘要(条目:分类排行数量:列出分类数:文件名:)` | `LogKit.exportSummary(_:listedCategories:fileName:)` / `LogKit.exportSummary(of:topCategories:listedCategories:fileName:)` |
| `LogKit.最近日志` / `LogKit.清空最近日志()` | `LogKit.recentEntries` / `LogKit.clearRecentEntries()` |
| `LogKit.过滤日志(条目, 条件:)` / `LogKit.过滤最近日志(条件)` | `LogKit.filterEntries(_:matching:)` / `LogKit.filteredRecentEntries(matching:)` |
| `LogKit.统计摘要(条目, 分类排行数量:)` / `LogKit.最近日志摘要(分类排行数量:)` | `LogKit.summary(of:topCategories:)` / `LogKit.summaryOfRecentEntries(topCategories:)` |
| `LogKit.导出压缩包(含归档:文件名:)` | `LogKit.exportArchive(includeArchived:fileName:)` |
| `LogKit.按链路聚合(条目, 未标记键:)` / `LogKit.合并日志(包含归档:)` | `LogKit.groupByTrace(_:untrackedKey:)` / `LogKit.mergeLogFiles(includeArchived:)` |
| `LogKit.Markdown报告(摘要, 列出分类数:)` / `LogKit.导出Markdown(摘要:列出分类数:文件名:)` / `LogKit.导出Markdown(条目:分类排行数量:列出分类数:文件名:)` | `LogKit.markdownString(_:listedCategories:)` / `LogKit.exportMarkdown(_:listedCategories:fileName:)` / `LogKit.exportMarkdown(of:topCategories:listedCategories:fileName:)` |
| `LogKit.HTML报告(摘要, 列出分类数:)` / `LogKit.导出HTML(摘要:列出分类数:文件名:)` / `LogKit.导出HTML(条目:分类排行数量:列出分类数:文件名:)` | `LogKit.htmlString(_:listedCategories:)` / `LogKit.exportHTML(_:listedCategories:fileName:)` / `LogKit.exportHTML(of:topCategories:listedCategories:fileName:)` |
| `LogKit.按消息聚合(条目, 去空白:忽略大小写:最多组数:)` | `LogKit.groupByMessage(_:trimWhitespace:ignoringCase:top:)` |
| `LogKit.增量日志(起始:条目:)` / `LogKit.导出增量(起始:包含归档:文件名:)` / `LogKit.导出增量(上次:包含归档:文件名:)` | `LogKit.entries(since:in:)` / `LogKit.exportSince(_:includeArchived:fileName:)` / `LogKit.exportSince(after:includeArchived:fileName:)` |
| `LogKit.日志体积` / `LogKit.清理归档日志()` | `LogKit.logStorage` / `LogKit.clearArchivedLogs()` |
| `消息聚合组` / `日志体积统计`（`日志文件项`） | `MessageGroup`（`.消息/.组内日志/.分类/.级别/.次数/.最早时间/.最晚时间/.级别名/.摘要文本` + `聚合成组(_:去空白:忽略大小写:最多组数:)`）/ `LogStorage`（`.文件/.文件数/.总字节/.总大小文本/.清单文本` + `人性化大小(_:)`）|
| `LogEntry.产生时间` | `LogEntry.date` |
| `日志模板` | `LogTemplate`（`.模板` / `.渲染(条目)` / `.formatter` + `占位符(模板)` / `未知占位符(模板)`）|
| `日志过滤条件` / `日志摘要` | `LogFilter`（`.按关键字/.按级别/.按追踪ID/.时间段(从:到:)/.为空/.匹配(_:)/.过滤(_:)`）/ `LogSummary`（`.总计/.各级别条数/.最早时间/.最晚时间/.级别条数/.错误条数/.错误率/.时间跨度/.分类排行/.摘要文本`）|
| `LogKit.CSV字符串(条目:含表头:)` / `LogKit.导出CSV(条目:文件名:)` | `LogKit.csvString(from:includeHeader:)` / `LogKit.exportCSV(_:fileName:)` |
| `LogEntry.JSON字典` / `LogEntry.JSON字符串` | `LogEntry.jsonObject` / `LogEntry.jsonString` |
| `作用域日志器` | `ScopedLogger`（`.调试/.信息/.警告/.错误/.严重/.计时/.子日志器`）|
| `性能计数器` | `PerformanceCounter`（`.计时/.异步计时/.汇总/.输出报告/.重置` 及 `调用次数/总耗时/平均耗时/最大耗时/最小耗时`）|
| `系统日志器` | `OSLogger`（`.调试/.信息/.通知/.错误/.严重/.故障`）|

## 高级用法：作用域日志器 / 性能计数器 / 系统日志

**作用域日志器 `ScopedLogger`**：每个模块各持一个，绑定默认分类，实例方法免传分类：

```swift
let 网络 = ScopedLogger(module: "网络", category: "请求")
网络.调试("开始拉取用户信息")          // 分类自动为「网络.请求」
网络.警告("请求超时")
let 重试 = 网络.child("重试")           // 分类 → 网络.请求.重试
```

**性能计数器 `PerformanceCounter`**：持续累计、按需汇总，不刷屏：

```swift
let 解码 = PerformanceCounter("图片解码")
for _ in 0..<100 { 解码.measure { imageLoader.decode(data) } }
解码.输出报告()   // 「图片解码」调用 100 次 · 总耗时 1.20 s · 平均 12.0 ms · ...
```

**系统日志桥接 `OSLogger`**：封装 `os.Logger`，日志直达 Console.app：

```swift
let 系统日志 = OSLogger(subsystem: "com.example.app", category: "网络")
系统日志.信息("用户登录成功")
系统日志.错误("请求失败")
```

**日志限流 `throttled`**：同一键（默认「文件:行:级别」）在窗口内只输出一次，适合滚动回调等高频场景：

```swift
for offset in 0..<1000 {
    LogKit.限流日志("滚动位置 \(offset)", 间隔: 1)   // 1 秒内只输出第一条
}
LogKit.重置限流()   // 清除全部限流记录，下次立即输出
```

**敏感信息脱敏**：默认开启，按字段名关键词把值替换为 `***`；可单独调用 `redact` 或关闭：

```swift
LogKit.info("登录", fields: ["账号": "张三", "password": "secret"])   // password → ***
LogKit.redact(["token": "abc"])            // ["token": "***"]
LogKit.脱敏敏感字段 = false                 // 关闭自动脱敏
LogKit.敏感字段关键词.insert("card")        // 追加自定义关键词
```

**终端彩色输出**：仅作用于控制台的 `.text` 输出，按级别着色（调试灰 / 信息青 / 警告黄 / 错误红 / 严重红底白字），不影响文件与 JSON：

```swift
LogKit.彩色控制台 = true
```

**日志检索**：按关键字搜索当前或全部日志文件：

```swift
let 行 = LogKit.检索日志("网络请求失败")          // 当前日志文件
let 全部 = LogKit.检索全部日志("错误", 上限: 50)   // 目录下全部日志文件，最多 50 行
```

**日志采样 `sampled`**：高频日志按概率随机保留，被丢弃时消息不构造（惰性）：

```swift
LogKit.采样率 = 0.05                          // 全局默认采样率改为 5%
for index in 0..<1000 {
    LogKit.采样日志("高频事件 \(index)", 采样率: 0.1)   // 约 10% 概率输出
}
```

**日志导出 `exportLogs`**：复制当前日志文件到临时目录，交给系统分享面板：

```swift
do {
    let url = try LogKit.导出日志()
    // iOS：UIActivityViewController(activityItems: [url], ...)
    // macOS：NSSharingServicePicker(items: [url])
} catch {
    print("导出失败：\(error.localizedDescription)")
}
```

**崩溃兜底 `installCrashHandler`**：在 App 启动早期调用一次，捕获未捕获异常与致命信号：

```swift
LogKit.安装崩溃处理()   // 崩溃日志写入 LogKit.崩溃日志路径
```

**自定义输出去向 `addSink`**：在控制台 / 文件之外再挂第三方接收者（上报服务端、自建日志面板等）。
sink 收到的是完整 `LogEntry`，且同样经过级别 / 分类过滤，只有真正输出的日志才会派发：

```swift
// 登记一个把警告及以上日志上报到服务端的去向，返回登记标识
let 上报 = LogKit.添加输出 { 条目 in
    guard 条目.level >= .warning else { return }
    上报服务端(条目.jsonObject)
}

LogKit.输出数量          // 当前登记的去向数量
LogKit.移除输出(上报)    // 按标识移除；也可用 LogKit.清空输出() 一次清空
```

> 派发时先复制去向快照再回调，回调里可以安全地 `添加输出` / `移除输出`，不会死锁。
> 只有 `onLog != nil` 或存在去向时才会组装 `LogEntry`，无接收方时不产生额外开销。

**CSV 导出 `exportCSV`**：把日志条目导出成 CSV 交给表格软件 / 数据分析。`fields` 的键会
自动展开成独立列（列集合取所有条目的并集并按键排序），并写入 UTF-8 BOM，Excel 打开中文不乱码：

```swift
// 用 onLog / addSink 收集条目
var 收集: [LogEntry] = []
let 去向 = LogKit.添加输出 { 收集.append($0) }

LogKit.信息("用户登录成功", 分类: "账号", fields: ["接口": "/api/user", "状态码": 200])
LogKit.警告("网络请求超时", 分类: "网络")

let 文本 = LogKit.CSV字符串(条目: 收集)          // 只取文本，含表头
let 文件 = try LogKit.导出CSV(收集)              // 写入临时目录，返回文件 URL
// iOS：UIActivityViewController(activityItems: [文件], ...)
// macOS：NSSharingServicePicker(items: [文件])
LogKit.移除输出(去向)
```

CSV 列顺序为 `time, level, levelValue, category, message, file, line, traceId`，其后是各
`fields` 键（按字典序）。字段值里的逗号、引号、换行会自动用双引号包裹转义。

**时区配置 `timeZone`**：统一时间戳与日志文件名日期的时区，便于跨时区排查或统一按 UTC 归档：

```swift
LogKit.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS Z"
LogKit.时区 = TimeZone(identifier: "UTC")!   // 之后所有时间戳与文件名日期均按 UTC
```

**按天数清理 `maxLogAgeDays`**：自动删除超过 N 天的日志文件，可与按数量清理 `maxLogFiles` 叠加：

```swift
LogKit.日志保留天数 = 7      // 只保留最近 7 天的日志文件
LogKit.maxLogFiles = 30      // 同时最多保留 30 个文件
LogKit.轮转日志()            // 触发一次检查；当前正在写入的文件始终不会被删除
```

**内存检索与过滤 `LogFilter`**：把最近若干条日志留在内存，随时按条件筛，不用读文件：

```swift
LogKit.最近保留条数 = 500        // 之后每条日志都会缓存进内存（环形，超出丢最旧）

// 组合条件：错误级以上 + 网络分类 + 关键字
let 条件 = LogFilter(级别: [.error, .critical], 分类: ["网络"], 关键字: "超时")

LogKit.最近日志.count                        // 当前缓存的条数
LogKit.过滤最近日志(条件)                    // 内存里直接筛
LogKit.过滤日志(LogKit.最近日志, 条件: 条件)  // 等价写法
LogKit.清空最近日志()                        // 用完清掉，释放内存
```

单独的过滤条件也可用静态方法拼装：`LogFilter.按关键字("超时")`、`LogFilter.按级别(.error)`、
`LogFilter.按追踪ID("req-1")`、`LogFilter.时间段(从: 起点, 到: 终点)`（`到` 可省略）。
`关键字` 会扫描消息、分类、追踪 ID、文件名与字段值（不区分大小写）；`LogFilter().为空` 可判断是否没设任何条件。

> 中文构造器的首参 `级别` 没有默认值，这样零参写法 `LogFilter()` 才不会与英文
> `init(levels:categories:keyword:from:to:traceId:)`（参数全有默认值）产生歧义。
> 只想按分类 / 关键字筛时，把 `级别` 显式传 `nil` 即可：`LogFilter(级别: nil, 分类: ["网络"])`。

**统计摘要 `LogSummary`**：一眼看清这段时间的日志概况，适合做开发面板或随崩溃报告一起上报：

```swift
let 摘要 = LogKit.最近日志摘要()
print(摘要.摘要文本())
// 日志共 128 条
// 各级别：调试 96，信息 24，警告 6，错误 2，严重 0
// 错误率：1.6%
// 时间跨度：42.31 秒
// 分类排行：网络(64)，存储(32)，账号(32)

摘要.错误条数       // 错误 + 严重
摘要.错误率         // 0.0 ~ 1.0
摘要.时间跨度       // 秒；条数不足时 nil
摘要.分类排行       // 次数从多到少，次数相同按分类名排序（结果稳定可复现）
```

**压缩归档导出 `exportArchive`**：把当前日志、崩溃日志、历史归档一次性打包成 zip 交给用户：

```swift
let 压缩包 = try LogKit.导出压缩包()                 // 含归档，返回 zip 的 URL
let 仅当前 = try LogKit.导出压缩包(含归档: false, 文件名: "问题反馈")
// iOS：UIActivityViewController(activityItems: [压缩包], ...)
// macOS：NSSharingServicePicker(items: [压缩包])
```

zip 由纯 Foundation 手写生成（存储方式、不压缩，文件名标记 UTF-8），macOS 访达、Windows
资源管理器、`unzip` 都能直接打开，不引入任何第三方依赖。目录里一条日志都没有时抛出
`LogKitError.logFileNotFound`。

**按天自动轮转 `dailyRotation`**：默认关闭，开启后跨天第一次写日志时，自动把前一天的
`LogKit-yyyy-MM-dd.log` 归档改名为 `LogKit-旧日期-时间戳.log`，当天的日志从新文件写起：

```swift
LogKit.fileOutput = true
LogKit.按天轮转 = true    // 跨天后自动归档昨天的文件（崩溃日志不受影响）
```

配合 `maxFileSize` / `maxLogFiles` / `maxLogAgeDays` 一起用，按天分文件 + 按需清理，长期运行也不会堆满磁盘。

**按小时自动轮转 `hourlyRotation`**：与按天版同源，只是粒度到小时，适合高频日志或长跑压测：

```swift
LogKit.fileOutput = true
LogKit.按小时轮转 = true    // 跨小时后自动归档上一小时的文件（LogKit-yyyy-MM-dd-HH.log）
```

归档判定只认「每年 4 位、其余各段恰好 2 位」的名字，已归档名末尾多出的 9 位时间戳
（`HHmmssSSS`）不会被当成待归档文件，因此不会反复改名。

**JSON 导出 `exportJSON` / `jsonString`**：把一批日志条目导出成 JSON 数组文件，便于交给采集 / 分析工具：

```swift
// 用 onLog / addSink 收集条目
var 收集: [LogEntry] = []
let 去向 = LogKit.添加输出 { 收集.append($0) }
LogKit.信息("用户登录成功", 分类: "账号", fields: ["状态码": 200])

let 文本 = LogKit.JSON字符串(条目: 收集)          // 只取文本，默认美化（带缩进换行）
let 紧凑 = LogKit.JSON字符串(条目: 收集, 美化: false)
let 文件 = try LogKit.导出JSON(收集, 文件名: "问题反馈")   // 写入临时目录，返回文件 URL
LogKit.移除输出(去向)
```

JSON 采用 `.sortedKeys` 键序稳定、可复现，且**不写 UTF-8 BOM**（BOM 会让严格的 JSON 解析器报错）；
CSV 导出则保留 BOM 以便 Excel 正确识别中文。

**日志反解析 `parseLogFile`**：把 `.text` 格式日志读回 `LogEntry`，可直接喂给 `LogFilter` / `LogSummary` / 再导出：

```swift
let 条目 = LogKit.日志反解析(文件: LogKit.logFileURL)      // 按行反解析，认不出的行跳过
let 最近的 = LogKit.日志反解析(一段日志文本)                // 也可以直接吃字符串（剪贴板 / 网络）
let 单条 = LogKit.解析日志行("[2026-09-10 10:00:00.000] [信息] [账号] 登录成功 @ Login.swift:42")

print(LogKit.summary(of: 条目).text())                     // 反解析后即可统计
```

解析时从**尾部**依次剥掉「字段块 → 追踪 ID 块 → 位置」，剩下的才是消息原文，所以消息里
含空格、冒号、方括号也不会被误伤；级别同时接受中文名（`信息`）与英文名（`info` / `warn` / `fatal`）。
字段值一律按字符串处理，且**值里含逗号会截断**（本库文本输出未对逗号转义），JSON 格式的日志行请自行用 `JSONSerialization` 解析。

**摘要导出 `exportSummary`**：把 `LogSummary` 写成中文摘要文本文件，随问题反馈一起提交：

```swift
let 文件 = try LogKit.导出摘要(条目: 条目, 文件名: "日志摘要")
// 或先拿到摘要对象再导出：try LogKit.导出摘要(LogKit.summary(of: 条目))
// iOS：UIActivityViewController(activityItems: [文件], ...)
// macOS：NSSharingServicePicker(items: [文件])
```

导出内容为「LogKit 日志摘要 + 生成时间 + 摘要正文」，分类排行默认最多列出 3 项，可用 `列出分类数` 调整。

**日志格式模板 `LogTemplate`**：只想换个顺序 / 分隔符时，不必写 `customFormatter` 闭包，用一段带占位符的字符串即可：

```swift
let 模板 = 日志模板("{级别} | {分类} | {消息} @ {文件}:{行}")
LogKit.customFormatter = 模板.formatter      // 直接接管全部日志的拼装
LogKit.信息("用户登录成功", 分类: "账号")
// 信息 | 账号 | 用户登录成功 @ LoginViewModel.swift:42

LogTemplate.unknownPlaceholders(in: "{级别} {不存在的}")   // ["不存在的"]，启动时自查拼错的占位符
```

占位符英文 / 中文两种写法等价：`{time}`/`{时间}`、`{level}`/`{级别}`、`{category}`/`{分类}`、`{message}`/`{消息}`、`{file}`/`{文件}`、`{line}`/`{行}`、`{traceId}`/`{追踪ID}`、`{fields}`/`{字段}`（形如 `键=值, 键=值`，按键名排序）。
**写错的占位符会原样保留**（含花括号），不会被静默吞成空串——一眼就能看出模板写错了。

**按 traceId 聚合 `groupByTrace`**：一次请求的日志散落在各处时，按 `traceId` 归组还原完整链路：

```swift
let 分组 = LogKit.按链路聚合(条目)              // [traceId: [LogEntry]]，组内按时间从早到晚
for (链路, 日志) in 分组 {
    print("链路 \(链路) 共 \(日志.count) 条")
}

// 没有 traceId 的散装日志不会丢，统一归到「未标记」桶（键名可自定义）
let 严格 = LogKit.groupByTrace(条目, untrackedKey: "无链路")
```

组内按时间升序；时间相同时保持传入顺序，结果稳定可复现。

**合并日志文件 `mergeLogFiles`**：把当前日志与全部归档一起读出来，按时间归并成一个完整日志流：

```swift
let 全部 = LogKit.合并日志()                 // 读之前先 flush()，缓冲区里的日志也进来
let 摘要 = LogKit.summary(of: 全部)          // 之后直接过滤 / 统计 / 再导出
LogKit.导出Markdown(摘要, 文件名: "本地会话")
```

解析规则与 `parseLogFile` 一致，认不出的行跳过；只想要当前文件时传 `包含归档: false`。

**Markdown 报告 `exportMarkdown`**：把摘要写成 Markdown 表格，直接粘进 GitHub issue / 飞书文档：

```swift
let 文本 = LogKit.Markdown报告(摘要)                     // 只取文本
let 文件 = try LogKit.导出Markdown(条目, 文件名: "日志报告")   // 写成 .md 文件
```

输出包含「总览 / 各级别条数 / 分类排行」三张表（分类排行默认列 5 项，传 `列出分类数: 0` 可省掉）。
分类名里的 `|` 会自动转义成 `\|`，不会把表格撑坏。

**HTML 报告 `exportHTML`**：把摘要写成一张自包含网页，样式内联、不引用任何外部资源，双击即看：

```swift
let 网页 = LogKit.HTML报告(摘要)                          // 只取文本
let 文件 = try LogKit.导出HTML(条目, 文件名: "日志报告")      // 写成 .html 文件，浏览器直接打开
// iOS：UIActivityViewController(activityItems: [文件], ...)
// macOS：NSSharingServicePicker(items: [文件])
```

内容同样是「总览 / 各级别条数 / 分类排行」三张表（`列出分类数: 0` 可省掉分类表）。
消息 / 分类里的 `&` `<` `>` `"` `'` 会被转义（先换 `&` 再换其余，避免二次转义），不会把页面撑坏。

**按消息聚合 `groupByMessage`**：同一条消息刷了很多遍时，先归成组，一眼看清「哪句话刷得最多」：

```swift
LogKit.最近保留条数 = 500
// …运行一段时间…

for 组 in LogKit.按消息聚合(LogKit.最近日志) {
    print(组.摘要文本)      // 「12 次 · 错误 · 网络请求失败」
    print(组.次数)          // 12
    print(组.级别名)        // 错误（组内最高级别）
    print(组.分类)          // ["网络", "账号"]（去重、按字典序）
    print(组.最早时间, 组.最晚时间)
}
```

返回结果按「次数从多到少」排序，次数相同按消息字典序，保证同样输入总是同样顺序。
`去空白: true`（默认）会先去掉消息首尾空白再比，`忽略大小写: true` 可把 `Timeout` 与 `timeout` 并成一组，
`最多组数` 只取前 N 组。

**差异导出 `exportSince`**：只导出上次检查点之后的日志，适合增量备份 / 增量提报：

```swift
// 记下上次检查点
var 检查点 = Date()

// …运行一段时间后…
let 新增 = try LogKit.导出增量(检查点)              // 只含 检查点 之后（含）的日志，写成 CSV
检查点 = Date()

// 也可以「以上次看到的最后一条为界」
let 又一批 = try LogKit.导出增量(上次: 某条日志)
```

纯筛选用 `LogKit.增量日志(起始: 时刻, 条目: 条目)`，等价于按 `date >= 起始` 过滤；
`导出增量` 内部会先 `flush()` 并把当前日志与归档合并，该时段没有日志时导出的是只有表头的空表。

**体积统计与清理 `logStorage` / `clearArchivedLogs`**：看看日志占了多大空间，需要时一键清理：

```swift
let 体积 = LogKit.日志体积
print(体积.清单文本)
// 日志共 3 个文件，合计 1.5 MB
//   LogKit.log（当前） 312.0 KB
//   LogKit-2026-09-09-120000000.log 1.1 MB
//   LogKit-crash.log 4.0 KB

体积.文件数            // 3
体积.总字节            // 1572864
体积.总大小文本        // 「1.5 MB」

LogKit.清理归档日志()   // 删除全部归档文件（返回删除个数），保留当前日志与崩溃日志
LogKit.清空日志()       // 再清空当前日志，日志目录即清干净
```

`humanSize` / `人性化大小` 把字节数转成可读大小（不足 1 KB 按整数 `B`，否则保留一位小数的 `KB` / `MB` / `GB` / `TB`）。

## 更新日志

- **版本号规则变更（自 1.4.0 起）**：版本号改为「满十进位式」——次版本满 10 就进位到主版本。按此规则，`0.13.0` 的下一版写作 `1.4.0`（而不是 `0.14.0`）。此前已发布的 `0.x` tag 原样保留，上面的旧条目也保持原编号。

- **1.5.0**：新增 HTML 报告（`htmlString` / `HTML报告` 与 `exportHTML` / `导出HTML`，把摘要写成自包含网页，样式内联、零外部资源，`&` `<` `>` `"` `'` 先换 `&` 再转义其余，避免二次转义）、按消息聚合（`groupByMessage` / `按消息聚合` 与 `MessageGroup` / `消息聚合组`，相同消息归为一组，给出次数 / 最高级别 / 涉及分类 / 最早最晚时间，按次数降序、次数相同按消息字典序，支持去空白与忽略大小写）、差异导出（`exportSince(_:includeArchived:fileName:)` / `exportSince(after:includeArchived:fileName:)` / `导出增量` 与纯筛选 `entries(since:in:)` / `增量日志`，只导出某时刻或某条日志之后的条目为 CSV）、体积统计与清理（`logStorage` / `日志体积` 与 `LogStorage` / `日志体积统计`、`日志文件项`，逐个量出日志文件大小并汇总，`clearArchivedLogs` / `清理归档日志` 删除全部归档文件，`humanSize` / `人性化大小` 转可读大小），均含中文别名并补单元测试。

- **1.4.0**：新增按 `traceId` 聚合（`groupByTrace` / `按链路聚合`，按 traceId 分组还原一次请求的完整链路，组内按时间升序、时间相同保持传入顺序，无 traceId 的条目归到可自定义的 `untrackedKey` 桶）、合并日志文件（`mergeLogFiles` / `合并日志`，读取当前日志与全部归档并归并排序，读前先 `flush()`，沿用 `parseLogFile` 的解析规则）、格式模板（`LogTemplate` / `日志模板`，用 `{级别}` / `{时间}` 等占位符接管行格式，`.formatter` 可直接赋给 `customFormatter`，支持中英文占位符名，写错的占位符原样保留并提供 `unknownPlaceholders(in:)` 自查）、Markdown 报告（`markdownString` / `Markdown报告` 与 `exportMarkdown` / `导出Markdown`，输出总览 / 各级别条数 / 分类排行三张表格，单元格里的 `|` 自动转义），均含中文别名。

- **0.13.0**：新增 JSON 导出（`exportJSON` / `导出JSON` 与 `jsonString(from:prettyPrinted:)` / `JSON字符串(条目:美化:)`，导出 JSON 数组文件，键序稳定、默认美化、不写 BOM）、日志反解析（`parseLogLine` / `解析日志行` + `parseLogFile(_:)` / `日志反解析(_:)` + `parseLogFile(at:)` / `日志反解析(文件:)`，从尾部剥掉「字段 → traceId → 位置」还原消息，级别兼容中英文名，可喂给 `LogSummary` / `LogFilter`）、摘要导出（`exportSummary(_:listedCategories:fileName:)` / `exportSummary(of:topCategories:listedCategories:fileName:)` / `导出摘要`，把摘要写成中文文本文件）、按小时自动轮转（`hourlyRotation` / `按小时轮转`，文件名 `LogKit-yyyy-MM-dd-HH.log`，归档判定只认「年 4 位、其余各段 2 位」，已归档名不会被二次改名），均含中文别名并补单元测试。

- **0.12.1**：修复 `ZipWriter` 在较旧工具链上的编译超时。打包 zip 时计算 DOS 时间戳的表达式把多个 `??`、位移、按位或与最外层 `UInt16(...)` 挤在一行，类型推断组合爆炸，CI 报 `unable to type-check this expression in reasonable time`。现拆成具名的 `Int` 常量再拼位，计算结果与产出的 zip 完全不变。

- **0.12.0**：新增条目过滤（`LogFilter` / `日志过滤条件`，按级别 / 分类 / 关键字 / 时间段 / 追踪 ID 组合筛选 `LogEntry`，另有 `filterEntries(_:matching:)` / `过滤日志` 与静态构造 `按关键字` / `按级别` / `按追踪ID` / `时间段`）、内存检索（`maxRecentEntries` / `最近保留条数` 缓存最近 N 条，`recentEntries` / `最近日志` / `clearRecentEntries` / `清空最近日志` / `filteredRecentEntries` / `过滤最近日志`，`NSLock` 保护，为 `0` 时不缓存零开销）、统计摘要（`LogSummary` / `日志摘要`，条数 / 各级别条数 / 错误率 / 时间跨度 / 分类排行，`text()` 产出中文摘要，排行次数相同按分类名排序保证稳定）、压缩归档导出（`exportArchive` / `导出压缩包`，纯 Foundation 手写 ZIP 打包当前 + 崩溃 + 归档日志，零依赖，无文件时抛 `logFileNotFound`）、按天自动轮转（`dailyRotation` / `按天轮转`，跨天写入自动归档前一天的按天日志文件），`LogEntry` 新增 `date` / `产生时间`（真正的时间点，不受 `dateFormat` 影响，供时间段筛选），均含中文别名并补单元测试。中文构造器 `init(级别:分类:关键字:起始时间:结束时间:追踪ID:)` 的首参 `级别` 无默认值，以避免与英文零参 `LogFilter()`（参数全有默认值）产生「歧义调用」。

- **0.11.0**：新增自定义输出去向（`addSink` / `removeSink` / `removeAllSinks` / `sinkCount` / `添加输出` / `移除输出` / `清空输出` / `输出数量`，在控制台 / 文件之外挂第三方接收者，`NSLock` 保护、先复制快照再回调避免重入死锁，仅在有接收方时才组装 `LogEntry`）、按天数清理（`maxLogAgeDays` / `日志保留天数`，按修改时间删除过期日志文件，与 `maxLogFiles` 叠加，当前文件不删）、CSV 导出（`exportCSV` / `csvString(from:includeHeader:)` / `导出CSV` / `CSV字符串(条目:含表头:)`，`fields` 自动展开成独立列、键排序、双引号转义、UTF-8 BOM 防中文乱码）、时区配置（`timeZone` / `时区`，统一时间戳与日志文件名日期），均含中文别名并补单元测试。

- **0.10.0**：新增输出预判（`isEnabled(level:category:)` / `是否输出(级别:分类:)`，提前判断日志是否会被输出，避免无谓的消息构造）、作用域追踪（`withTrace` / `withTraceAsync` / `追踪执行` / `异步追踪执行`，临时设置 `traceId` 并在执行完自动恢复，抛错时也恢复）、单条序列化（`LogEntry.jsonObject` / `jsonString` / `JSON字典` / `JSON字符串`，把任意日志条目转成结构化字典 / JSON 字符串，`jsonString` 采用 `.sortedKeys` 键序稳定可复现），均含中文别名并补单元测试。

- **0.9.0**：新增日志回调钩子（`onLog` / `日志回调`，每条日志输出后回调完整 `LogEntry`）、尾部读取（`tail` / `尾部读取`，读取当前日志文件末尾若干行）、归档列表（`archivedLogFiles` / `归档日志列表`，按时间倒序列出已归档日志文件），均含中文别名并补单元测试。

- **0.8.1**：修复 `exportLogs` / `导出日志` 导出的目标文件名仅精确到毫秒、同一毫秒内多次导出会因同名碰撞导致 `copyItem` 失败的问题（目标文件名追加短 UUID 保证唯一）；消除崩溃兜底写文件时 `try?` 返回值未使用的编译告警。

- **0.8.0**：新增日志采样（`sampled` / `采样日志` / `samplingRate` / `采样率`，按概率随机输出、高频日志降噪，被丢弃时惰性不求值）、日志导出（`exportLogs` / `导出日志`，复制当前日志文件到临时目录供系统分享面板）、崩溃兜底（`installCrashHandler` / `安装崩溃处理` / `crashLogFileURL` / `崩溃日志路径`，捕获未捕获 `NSException` 与 `SIGABRT` / `SIGSEGV` 等致命信号写入崩溃日志），均含中文别名并补单元测试。

- **0.7.0**：新增日志限流（`throttled` / `限流日志` / `resetThrottle` / `重置限流`，按「文件:行:级别」或自定义键去重）、敏感信息脱敏（`redactSensitiveData` / `sensitiveFieldKeywords` / `redact` / `脱敏`，按字段名关键词替换为 `***`）、终端彩色输出（`coloredConsoleOutput` / `彩色控制台`，仅控制台 `.text` 按级别着色）、日志检索（`search` / `searchAllFiles` / `检索日志` / `检索全部日志`，按关键字搜当前 / 全部日志文件，含 `limit`），均含中文别名并补单元测试。

- **0.6.0**：新增追踪 ID（`traceId` 全局 + `ScopedLogger.traceId` 两级，`LogEntry` 与 JSON 输出均带 `traceId` 字段，`ScopedLogger.child` 自动继承）、环境自适应默认级别（`minimumLevel` 默认 DEBUG `.debug` / RELEASE `.warning`，提供只读 `adaptiveMinimumLevel`）、级别计数统计（`totalCount(by:)` / `totalCount()` / `resetCounts()`，只统计通过过滤真正输出的日志），均含中文别名。

- **0.5.1**：修复惰性求值失效（被级别 / 分类过滤的日志不再提前执行消息构造），并新增单元测试（Tests target，14 用例）。
- **0.5.0**：新增作用域日志器 `ScopedLogger`（`模块/分类` 绑定默认分类，`debug/info/warning/error/critical` 免传分类 + `measure/measureAsync/child`）、性能计数器 `PerformanceCounter`（`record/measure/measureAsync` 累计 + `callCount/totalDuration/averageDuration/maxDuration/minDuration` + `summary/report/reset`）、系统日志桥接 `OSLogger`（封装 `os.Logger`，`subsystem/category` + `debug/info/notice/error/critical/fault`，消息 `.public` 隐私级），均含中文别名。

- **0.4.0**：新增耗时测量（`measure` / `measureAsync` / `计时` / `异步计时`，执行代码块并输出耗时，抛错时记录「失败 · 耗时」）、结构化字段（五级日志方法新增 `fields` 参数，JSON 输出成为 `fields` 子对象，文本输出追加 `[key=value]`）、自定义格式闭包（`customFormatter` / `自定义格式`，接收 `LogEntry` 完全接管日志拼装），均含中文别名。
- **0.3.0**：新增 JSON 结构化输出（`outputFormat = .json`，含时间/级别/级别值/分类/消息/位置字段）与异步写文件（`asyncWrite` 后台串行队列落盘，`flush` / `刷新缓冲` 等待落盘，`严重` 日志始终同步），均含中文别名。
- **0.2.0**：新增文件轮转（`maxFileSize` 按大小归档、`maxLogFiles` 按数量清理、`rotateLogFile` / `轮转日志` 主动轮转）与分类过滤（`enabledCategories` 白名单 / `ignoredCategories` 黑名单）。
- **0.1.0**：首个版本，五级日志、分级过滤、控制台 / 文件双输出、中文命名别名。

## License

MIT
