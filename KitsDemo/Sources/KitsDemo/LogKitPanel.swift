import SwiftUI
import AppKit
import Foundation
import LogKit

/// LogKit 日志分区：路径展示 / 写日志 / 采样 / 导出 / 崩溃兜底
struct LogKitPanel: View {

    @State private var status = "尚未操作"
    @State private var samplingRate: Double = LogKit.samplingRate
    @State private var hourlyRotation = LogKit.hourlyRotation

    var body: some View {
        VStack(spacing: 20) {
            Card("日志路径") {
                VStack(alignment: .leading, spacing: 6) {
                    row("日志目录", LogKit.logDirectory.path)
                    row("当前日志", LogKit.logFileURL.path)
                    row("崩溃日志", LogKit.crashLogFileURL.path)
                }
            }

            Card("写日志（info / warning / error）") {
                HStack {
                    Button("写 info") {
                        LogKit.info("演示日志：\(Date())", category: "演示")
                        status = "已写一条 info 日志"
                    }
                    Button("写 warning") {
                        LogKit.warning("演示警告", category: "演示")
                        status = "已写一条 warning 日志"
                    }
                    Button("写 error") {
                        LogKit.error("演示错误", category: "演示")
                        status = "已写一条 error 日志"
                    }
                }
            }

            Card("日志采样 sampled（高频降噪 · 惰性求值）") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("全局采样率 samplingRate")
                        Spacer()
                        Text("\(Int(samplingRate * 100))%")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $samplingRate, in: 0...1) { editing in
                        if !editing { LogKit.samplingRate = samplingRate }
                    }
                    Button("批量采样 100 条（rate 0.1 ≈ 10% 落盘）") {
                        for i in 0..<100 {
                            LogKit.sampled("高频事件 #\(i)", rate: 0.1, category: "采样")
                        }
                        status = "已按 0.1 采样率输出 100 条（实际约 10 条落盘）"
                    }
                }
            }

            Card("导出与崩溃兜底") {
                VStack(alignment: .leading, spacing: 10) {
                    Button("导出日志 exportLogs") {
                        do {
                            let url = try LogKit.exportLogs()
                            status = "导出成功：\(url.path)"
                            NSWorkspace.shared.activateFileViewerSelecting([url])
                        } catch {
                            status = "导出失败：\(error)"
                        }
                    }
                    Button("安装崩溃兜底 installCrashHandler") {
                        LogKit.installCrashHandler()
                        status = "已安装崩溃兜底，崩溃日志：\(LogKit.crashLogFileURL.path)"
                    }
                    Text(status)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Card("日志反解析 parseLogFile（把 .text 读回条目，再做统计 / 导出）") {
                VStack(alignment: .leading, spacing: 10) {
                    Button("反解析当前日志文件并统计") {
                        let entries = LogKit.parseLogFile(at: LogKit.logFileURL)
                        let summary = LogKit.summary(of: entries)
                        let rate = String(format: "%.1f", summary.errorRate * 100)
                        status = "反解析出 \(entries.count) 条；错误 \(summary.errorCount) 条，错误率 \(rate)%"
                    }
                    Button("导出 JSON exportJSON") {
                        do {
                            let entries = LogKit.parseLogFile(at: LogKit.logFileURL)
                            let url = try LogKit.exportJSON(entries, fileName: "LogKit演示")
                            status = "JSON 导出成功：\(url.path)"
                            NSWorkspace.shared.activateFileViewerSelecting([url])
                        } catch {
                            status = "JSON 导出失败：\(error)"
                        }
                    }
                    Button("导出摘要 exportSummary") {
                        do {
                            let entries = LogKit.parseLogFile(at: LogKit.logFileURL)
                            let url = try LogKit.exportSummary(条目: entries, 文件名: "LogKit摘要")
                            status = "摘要导出成功：\(url.path)"
                            NSWorkspace.shared.activateFileViewerSelecting([url])
                        } catch {
                            status = "摘要导出失败：\(error)"
                        }
                    }
                }
            }

            Card("按小时自动轮转 hourlyRotation（跨小时自动归档上一小时的文件）") {
                VStack(alignment: .leading, spacing: 10) {
                    Button(hourlyRotation ? "关闭按小时轮转" : "开启按小时轮转") {
                        hourlyRotation.toggle()
                        LogKit.hourlyRotation = hourlyRotation
                        status = hourlyRotation
                            ? "已开启：跨小时后自动归档 LogKit-yyyy-MM-dd-HH.log"
                            : "已关闭按小时轮转"
                    }
                    Text(hourlyRotation ? "当前状态：开启" : "当前状态：关闭")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .frame(width: 72, alignment: .leading)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.callout.monospaced())
                .textSelection(.enabled)
        }
    }
}
