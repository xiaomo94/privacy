import SwiftUI
import CodeScanner

struct MGQRCodeScannerView: View {
        
    @Environment(\.dismiss) private var dismiss
    
    private let onCompletion: (Swift.Result<ScanResult, ScanError>) -> Bool
    
    init(onCompletion: @escaping (Swift.Result<ScanResult, ScanError>) -> Bool) {
        self.onCompletion = onCompletion
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                CodeScannerView(codeTypes: [.qr]) {
                    if onCompletion($0) {
                        dismiss()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(16)
                .frame(width: proxy.size.width, height: proxy.size.width)
                Spacer()
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    HStack {
                        Spacer()
                        Text("Close")
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(8)
                        Spacer()
                    }
                }
                .padding(16)
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle(Text("Scan QR Code"))
    }
}
