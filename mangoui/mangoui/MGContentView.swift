import SwiftUI

struct MGContentView: View {
    
    @StateObject private var packetTunnelManager        = MGPacketTunnelManager()
    @StateObject private var configurationListManager   = MGConfigurationListManager()
    
    @AppStorage(MGConfiguration.currentStoreKey, store: .shared) private var current: String = ""
    
    var body: some View {
        MGHomeView(current: $current)
            .environmentObject(packetTunnelManager)
            .environmentObject(configurationListManager)
    }
}
