import SwiftUI
import SystemInfoKit

/// SystemInfoKit 系统分区：网络流量 / 磁盘读写 / 内存明细 / 每核 CPU / 电池电源 / 已安装应用
struct SystemInfoKitPanel: View {

    @State private var network: NetworkTraffic?
    @State private var disk: DiskIOTraffic?
    @State private var status = "点击下方按钮采样"
    @State private var topProcesses: [ProcessUsage] = []
    @State private var sortByMemory = true
    @State private var perCore: [Double] = []

    var body: some View {
        VStack(spacing: 20) {
            Card("网络流量统计 sampleNetworkTraffic") {
                VStack(alignment: .leading, spacing: 8) {
                    Button("采样网络流量") {
                        network = SystemInfoKit.sampleNetworkTraffic()
                        status = network == nil ? "未找到活跃网络接口" : "已采样网络流量"
                    }
                    if let t = network {
                        row("接口", t.interface)
                        row("累计接收", bytesText(t.receivedBytes))
                        row("累计发送", bytesText(t.sentBytes))
                        row("接收速率", bytesPerSecondText(t.receivedBytesPerSecond))
                        row("发送速率", bytesPerSecondText(t.sentBytesPerSecond))
                    } else {
                        Text("尚未采样，或当前无活跃接口").foregroundStyle(.secondary)
                    }
                }
            }

            Card("磁盘读写速率 sampleDiskIOTraffic（仅 macOS）") {
                VStack(alignment: .leading, spacing: 8) {
                    Button("采样磁盘读写") {
                        disk = SystemInfoKit.sampleDiskIOTraffic()
                        status = disk == nil ? "未读到磁盘 I/O 统计" : "已采样磁盘读写"
                    }
                    if let d = disk {
                        row("累计读取", bytesText(d.bytesRead))
                        row("累计写入", bytesText(d.bytesWritten))
                        row("读取速率", bytesPerSecondText(d.readBytesPerSecond))
                        row("写入速率", bytesPerSecondText(d.writeBytesPerSecond))
                    } else {
                        Text("尚未采样，或无法读取 IOKit 块存储统计").foregroundStyle(.secondary)
                    }
                }
            }

            Card("系统信息速览") {
                VStack(alignment: .leading, spacing: 8) {
                    row("系统", "\(SystemInfoKit.systemName) \(SystemInfoKit.systemVersion)")
                    row("设备", "\(SystemInfoKit.deviceName)（\(SystemInfoKit.deviceType)）")
                    row("内存总量", SystemInfoKit.memoryTotal)
                    row("可用内存", SystemInfoKit.availableMemory)
                    row("磁盘剩余", SystemInfoKit.diskFree)
                    row("启动时长", SystemInfoKit.systemUptimeString)
                }
            }

            Card("电池细分状态 batteryState（充电中 / 已充满 / 未接电源 / 未知）") {
                VStack(alignment: .leading, spacing: 8) {
                    row("细分状态", SystemInfoKit.batteryStateName)
                    row("电量", SystemInfoKit.batteryLevel.map { "\(Int($0 * 100))%" } ?? "—")
                    row("电池健康", SystemInfoKit.batteryHealth)
                }
            }

            Card("进程占用排行 topProcesses（仅 macOS · proc_pidinfo）") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Button("按内存排行 Top 8") {
                            sortByMemory = true
                            topProcesses = SystemInfoKit.topProcesses(by: .memory, limit: 8)
                            status = "已按内存排行 \(topProcesses.count) 个进程"
                        }
                        Button("按 CPU 排行 Top 8") {
                            sortByMemory = false
                            topProcesses = SystemInfoKit.topProcesses(by: .cpu, limit: 8)
                            status = "已按 CPU 排行 \(topProcesses.count) 个进程"
                        }
                    }
                    if topProcesses.isEmpty {
                        Text("尚未排行，点上方按钮").foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(topProcesses.enumerated()), id: \.offset) { index, process in
                            HStack {
                                Text("\(index + 1). \(process.name)")

                                Spacer()
                                Text(sortByMemory ? process.memory : String(format: "%.1f%%", process.cpuPercent))
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Card("网卡物理地址 primaryMACAddress / networkInterfaces") {
                VStack(alignment: .leading, spacing: 8) {
                    row("主网卡", SystemInfoKit.primaryMACAddress ?? "—")
                    ForEach(SystemInfoKit.networkInterfaces.filter { $0.macAddress != nil }, id: \.name) { interface in
                        row(interface.name, interface.macAddress ?? "—")
                    }
                }
            }

            Card("内存明细 memoryBreakdown（活跃 / 非活跃 / 联动 / 压缩 / 可丢弃 / 预读）") {
                VStack(alignment: .leading, spacing: 8) {
                    if let 明细 = SystemInfoKit.memoryBreakdown {
                        row("总容量", 明细.totalDescription)
                        row("已用", "\(明细.usedDescription)（\(明细.usedPercentText)）")
                        row("可用", 明细.availableDescription)
                        row("活跃", 明细.activeDescription)
                        row("非活跃", 明细.inactiveDescription)
                        row("联动", 明细.wiredDescription)
                        row("压缩", 明细.compressedDescription)
                    } else {
                        Text("无法读取内存明细").foregroundStyle(.secondary)
                    }
                }
            }

            Card("每核 CPU 使用率 perCoreCPUUsage（逐核采样 · 下标即核序号）") {
                VStack(alignment: .leading, spacing: 8) {
                    Button("采样每核 CPU（约 100ms）") {
                        perCore = SystemInfoKit.perCoreCPUUsage
                        status = perCore.isEmpty ? "取不到每核数据" : "已采样 \(perCore.count) 个逻辑核"
                    }
                    if perCore.isEmpty {
                        Text("点上方按钮采样").foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(perCore.enumerated()), id: \.offset) { index, value in
                            HStack {
                                Text("CPU\(index + 1)")
                                Spacer()
                                Text("\(Int((value * 100).rounded()))%")
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Card("电池温度与电源明细 batteryTemperature / powerAdapter（仅 macOS）") {
                VStack(alignment: .leading, spacing: 8) {
                    row("供电来源", SystemInfoKit.powerSourceName)
                    row("电池温度", SystemInfoKit.batteryTemperatureText)
                    row("循环次数", SystemInfoKit.batteryCycleCount.map { "\($0) 次" } ?? "不支持")
                    if let adapter = SystemInfoKit.powerAdapter {
                        row("适配器功率", adapter.wattsText)
                        row("协商电压", adapter.voltageText)
                        row("协商电流", adapter.currentText)
                    } else {
                        row("适配器", "未接电源 / 无内置电池")
                    }
                }
            }

            Card("已安装应用 installedApplications（仅 macOS · 扫 /Applications）") {
                VStack(alignment: .leading, spacing: 8) {
                    row("应用数量", "\(SystemInfoKit.installedApplicationCount)")
                    ForEach(SystemInfoKit.installedApplications.prefix(8)) { app in
                        row(app.name, app.versionText)
                    }
                    Text("（只列前 8 个）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(status)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .frame(width: 88, alignment: .leading)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.callout.monospaced())
                .textSelection(.enabled)
        }
    }
}
