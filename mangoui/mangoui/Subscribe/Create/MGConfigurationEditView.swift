import SwiftUI

struct MGConfigurationEditView: View {
    
    @ObservedObject private var vm: MGConfigurationEditViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
        
    init(vm: MGConfigurationEditViewModel) {
        self._vm = ObservedObject(initialValue: vm)
    }
    
    var body: some View {
        Form {
            Section {
                LabeledContent("Name") {
                    TextField("", text: $vm.name)
                }
                switch vm.model.protocolType {
                case .vless:
                    MGVLESSView(vm: vm)
                case .vmess:
                    MGVMessView(vm: vm)
                case .trojan:
                    MGTrojanView(vm: vm)
                case .shadowsocks:
                    MGShadowsocksView(vm: vm)
                case .dns, .freedom, .blackhole:
                    fatalError()
                }
            } header: {
                Text("Server")
            }
            Section {
                MGTransportView(vm: vm)
            } header: {
                Text("Transport")
            }
            Section {
                MGSecurityView(vm: vm)
            } header: {
                Text("Security")
            }
        }
        .lineLimit(1)
        .multilineTextAlignment(.trailing)
        .navigationTitle(Text(vm.model.protocolType.description))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    do {
                        try vm.save()
                        dismiss()
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                } label: {
                    Text("Done")
                }
                .fontWeight(.medium)
            }
        }
    }
}
