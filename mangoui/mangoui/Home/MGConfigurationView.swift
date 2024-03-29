import SwiftUI

struct MGConfigurationView: View {
    
    @AppStorage("XRAY_PROXY_TRAFFIC_UP", store: .shared) private var up: Double = 0
    @AppStorage("XRAY_PROXY_TRAFFIC_DOWN", store: .shared) private var down: Double = 0
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager
    
    @EnvironmentObject private var configurationListManager: MGConfigurationListManager
    
    let current: Binding<String>
    
    var body: some View {
        Group {
            if let configuration = configurationListManager.configurations.first(where: { $0.id == current.wrappedValue }) {
                LabeledContent("名称", value: configuration.attributes.alias)
                LabeledContent("类型", value: configuration.typeString)
                LabeledContent("最近更新") {
                    TimelineView(.periodic(from: Date(), by: 1)) { _ in
                        Text(configuration.attributes.leastUpdated.formatted(.relative(presentation: .numeric)))
                    }
                }
                if let status = packetTunnelManager.status, status == .connected {
                    LabeledContent("UP", value: "\(Int64(up))")
                    LabeledContent("DOWN", value: "\(Int64(down))")
                }
            } else {
                NoCurrentConfigurationView()
            }
        }
        .onAppear {
            configurationListManager.reload()
        }
    }
    
    @ViewBuilder
    private func NoCurrentConfigurationView() -> some View {
        HStack {
            Spacer()
            VStack(spacing: 20) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.largeTitle)
                Text("无当前配置")
            }
            .foregroundColor(.secondary)
            .padding()
            Spacer()
        }
    }
    
    private var currentConfigurationName: String {
        guard let configuration = configurationListManager.configurations.first(where: { $0.id == current.wrappedValue }) else {
            return configurationListManager.configurations.isEmpty ? "无" : "未选择"
        }
        return configuration.attributes.alias
    }
}
