import SwiftUI

struct MGVPNResettingView: View {
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager

    @State private var isPresented: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            Button("Reset VPN Configuration", role: .destructive) {
                isPresented.toggle()
            }
            .disabled(packetTunnelManager.status == nil)
            Spacer()
        }
        .alert("Reset", isPresented: $isPresented) {
            Button("Confirm", role: .destructive) {
                Task(priority: .high) {
                    try await packetTunnelManager.removeFromPreferences()
                    try await packetTunnelManager.saveToPreferences()
                }
            }
            Button("Cancel", role: .cancel, action: {})
        }
    }
}
