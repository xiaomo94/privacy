import SwiftUI

struct MGSettingsView: View {
    
    enum Destination: String, Identifiable, Hashable, Codable, CaseIterable {
        var id: Self { self }
        case log
        case asset
        case dns
        case route
        case inbound
        case outbound
        var title: String {
            switch self {
            case .log:      return "Log"
            case .asset:    return "Assets"
            case .dns:      return "DNS"
            case .route:    return "Route"
            case .inbound:  return "Inbound"
            case .outbound: return "Outbound"
            }
        }
        var systemImage: String {
            switch self {
            case .log:      return "doc"
            case .asset:    return "folder"
            case .dns:      return "network"
            case .route:    return "arrow.triangle.branch"
            case .inbound:  return "square.and.arrow.down"
            case .outbound: return "square.and.arrow.up"
            }
        }
        @ViewBuilder
        func view() -> some View {
            switch self {
            case .log:
                MGLogSettingView()
            case .asset:
                MGAssetView()
            case .dns:
                MGDNSSettingView()
            case .route:
                MGRouteSettingView()
            case .inbound:
                MGInboundView()
            case .outbound:
                MGOutboundView()
            }
        }
    }
    var body: some View {
        Form {
            Section {
                ForEach(Destination.allCases) { destination in
                    NavigationLink {
                        destination.view()
                    } label: {
                        Label(destination.title, systemImage: destination.systemImage)
                    }
                }
            }
            Section {
                MGVPNResettingView()
            }
        }
        .navigationTitle(Text("Settings"))
    }
}
