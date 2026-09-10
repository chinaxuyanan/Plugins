import SwiftUI
import SystemInfoKit

/// SystemInfoKit 系统分区：网络流量 / 磁盘读写 / 系统信息速览
struct SystemInfoKitPanel: View {

    @State private var network: NetworkTraffic?
    @State private var disk: DiskIOTraffic?
    @State private var status = "点击下方按钮采样"

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
