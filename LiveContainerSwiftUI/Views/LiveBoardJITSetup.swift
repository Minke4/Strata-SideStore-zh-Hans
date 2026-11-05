import SwiftUI
import UniformTypeIdentifiers

struct LiveBoardJITSetup: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("LCJITEnablerType", store: LCUtils.appGroupUserDefault) private var provider = JITEnablerType.BuiltIn.rawValue
    @AppStorage("StrataJITDeviceAddress", store: LCUtils.appGroupUserDefault) private var deviceAddress = "10.7.0.1"
    @AppStorage("StrataJITRemotePairPort", store: LCUtils.appGroupUserDefault) private var remotePairPort = "49152"
    @ObservedObject private var session = LiveBoardJITSession.shared
    @State private var importing = false
    @State private var hasPairing = FileManager.default.fileExists(atPath: LiveBoardBuiltInJIT.pairingURL.path)
    var body: some View {
        NavigationView {
            Form {
                Section("JIT 启用方式") {
                    Picker("使用以下方式启用 JIT", selection: $provider) {
                        ForEach(JITEnablerType.allCases) { Text($0.displayName).tag($0.rawValue) }
                    }
                    Button("使用内置 JIT") { provider = JITEnablerType.BuiltIn.rawValue }
                }
                if provider == JITEnablerType.BuiltIn.rawValue {
                    Section("首次配置") {
                        Label(hasPairing ? "已导入配对文件" : "需要配对文件", systemImage: hasPairing ? "checkmark.circle" : "doc.badge.plus")
                        Button(hasPairing ? "替换配对文件" : "导入远程配对文件") { importing = true }
                        if hasPairing {
                            Button("移除配对文件", role: .destructive) {
                                do { try FileManager.default.removeItem(at: LiveBoardBuiltInJIT.pairingURL); hasPairing = false; session.message = "已移除配对文件。" }
                                catch { session.message = error.localizedDescription }
                            }
                        }
                        Text("请在 iPhone 设置中启用开发者模式。使用“以 JIT 启动”前，请连接 LocalDevVPN 和 Wi-Fi。首次启动时可能需要下载开发者磁盘映像。")
                        Label(LCUtils.strataCanDebug() ? "已具备调试权限" : "缺少调试权限：需要重新签名", systemImage: LCUtils.strataCanDebug() ? "checkmark.shield" : "exclamationmark.shield")
                        Text("内置 JIT 使用客户进程来保持调试器连接。正常启动时，该进程会以全屏方式打开。安装 Strata 时请保留应用扩展。在较新的 iOS 版本上，还可能需要在该应用的设置中配置兼容的 JIT 脚本。").foregroundStyle(.secondary)
                    }
                    Section("设备连接") {
                        TextField("设备 IP（不含 /32）", text: $deviceAddress)
                            .keyboardType(.decimalPad).autocorrectionDisabled()
                        TextField("远程配对端口", text: $remotePairPort)
                            .keyboardType(.numberPad)
                        Text("请从可正常使用的 SideStore 连接中复制设备 IP/端点（Device IP/Endpoint）和远程配对端口（RemotePair Port）。这不会更改 VPN 设置。").font(.footnote).foregroundStyle(.secondary)
                    }.disabled(session.busy)
                    Section("连接检查") {
                        Button("准备设备") { perform("prepare") }.disabled(session.busy || !hasPairing)
                        Button("重置开发者磁盘映像缓存") { perform("reset") }.disabled(session.busy || !hasPairing)
                        if session.busy {
                            ProgressView("正在处理…")
                            Button("取消") { session.cancel() }
                        }
                        if let operationSucceeded = session.success {
                            Label(operationSucceeded ? "已完成" : "未能完成", systemImage: operationSucceeded ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundStyle(operationSucceeded ? .green : .orange)
                        }
                        if !session.message.isEmpty { Text(session.message).font(.footnote).textSelection(.enabled).accessibilityIdentifier("jit.status") }
                    }
                    Section("启动") {
                        Text("长按应用或打开其控制台选项，然后选择“以 JIT 启动”。Strata 会自动准备设备并连接辅助程序。错误信息会显示在启动窗口中。")
                    }
                } else {
                    Section("外部服务") {
                        Text("请先在所选服务中配置配对及所需连接，然后为应用选择“以 JIT 启动”。")
                        NavigationLink("服务设置") { LCSettingsView() }
                    }
                }
                if provider != JITEnablerType.BuiltIn.rawValue && !session.message.isEmpty { Section { Text(session.message) } }
                Section { NavigationLink("内存与签名权限") { StrataMemorySettings() } }
                Section { NavigationLink("免 JIT 配置与诊断") { LCJITLessDiagnoseView() } }
            }.navigationTitle("JIT 配置")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } }
                .fileImporter(isPresented: $importing, allowedContentTypes: [.data]) { result in
                    do {
                        let url = try result.get()
                        try LiveBoardBuiltInJIT.importPairing(url)
                        hasPairing = true
                        session.message = "已导入配对文件。请连接 LocalDevVPN，然后以 JIT 启动应用。"
                    } catch { session.message = error.localizedDescription }
                }
        }.navigationViewStyle(.stack)
    }
    private func perform(_ operation: String) { session.start(operation) }
}
