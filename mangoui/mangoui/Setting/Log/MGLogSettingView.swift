import SwiftUI

struct MGLogSettingView: View {
    
    @StateObject private var logViewModel = MGConfigurationPersistentViewModel<MGConfiguration.Log>()
    
    var body: some View {
        Form {
            Picker(selection: $logViewModel.model.errorLogSeverity) {
                ForEach(MGConfiguration.Log.Severity.allCases) { severity in
                    Text(severity.description)
                }
            } label: {
                Text("Level")
            }
            Toggle("Access", isOn: $logViewModel.model.accessLogEnabled)
            Toggle("DNS", isOn: $logViewModel.model.dnsLogEnabled)
        }
        .navigationTitle(Text("Log"))
        .onDisappear {
            self.logViewModel.save()
        }
    }
}
