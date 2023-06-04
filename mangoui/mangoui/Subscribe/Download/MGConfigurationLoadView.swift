import SwiftUI

struct MGConfigurationLoadView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var configurationListManager: MGConfigurationListManager
    
    @StateObject private var vm = MGConfigurationLoadViewModel()
    
    @State private var isFileImporterPresented: Bool = false
    
    let location: MGConfigurationLocation
    
    var body: some View {
        Form {
            Section {
                TextField("", text: $vm.name)
            } header: {
                Text("Name")
            }
            Section {
                HStack(spacing: 4) {
                    TextField("", text: $vm.urlString)
                        .disabled(isAddressTextFieldDisable)
                    if location == .local {
                        Button {
                            isFileImporterPresented.toggle()
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                        .fixedSize()
                    }
                }
            } header: {
                Text(addressTitle)
            }
            Section {
                Button {
                    Task(priority: .userInitiated) {
                        do {
                            try await vm.process(location: location)
                            await MainActor.run {
                                configurationListManager.reload()
                                dismiss()
                            }
                        } catch {
                            await MainActor.run {
                                MGNotification.send(title:"", subtitle: "", body: error.localizedDescription)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(buttonTitle)
                        Spacer()
                    }
                }
                .disabled(isButtonDisbale)
            }
        }
        .navigationTitle(Text(title))
        .navigationBarBackButtonHidden()
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let success):
                vm.urlString = success.path(percentEncoded: false)
                if vm.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    vm.name = success.deletingPathExtension().lastPathComponent
                }
            case .failure(let failure):
                MGNotification.send(title: "", subtitle: "", body: failure.localizedDescription)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.isProcessing {
                    ProgressView()
                }
            }
        }
        .disabled(vm.isProcessing)
    }
    
    private var title: String {
        switch location {
        case .local:
            return "Import from Files"
        case .remote:
            return "Download from URL"
        }
    }
    
    private var addressTitle: String {
        switch location {
        case .local:
            return "File"
        case .remote:
            return "URL"
        }
    }
    
    private var isAddressTextFieldDisable: Bool {
        switch location {
        case .local:
            return true
        case .remote:
            return false
        }
    }
    
    private var buttonTitle: String {
        switch location {
        case .local:
            return "Import"
        case .remote:
            return "Download"
        }
    }
    
    private var isButtonDisbale: Bool {
        guard !vm.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return true
        }
        switch location {
        case .local:
            return vm.urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .remote:
            return URL(string: vm.urlString.trimmingCharacters(in: .whitespacesAndNewlines)) == nil
        }
    }
}
