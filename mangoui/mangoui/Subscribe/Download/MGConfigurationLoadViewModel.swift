import Foundation

final class MGConfigurationLoadViewModel: ObservableObject {
        
    @Published var name:       String = ""
    @Published var urlString:  String = ""
    
    @Published var isProcessing: Bool = false
    
    func process(location: MGConfigurationLocation) async throws {
        await MainActor.run {
            isProcessing = true
        }
        let err: Error?
        do {
            switch location {
            case .local:
                try await processLocal()
            case .remote:
                try await processRemote()
            }
            err = nil
        } catch {
            err = error
        }
        await MainActor.run {
            isProcessing = false
        }
        try err.flatMap { throw $0 }
    }
    
    private func processLocal() async throws {
        let url = URL(filePath: urlString.trimmingCharacters(in: .whitespacesAndNewlines))
        guard url.startAccessingSecurityScopedResource() else {
            throw NSError.newError("无法访问该配置文件")
        }
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        try self.save(sourceURL: url, fileURL: url)
    }
    
    private func processRemote() async throws {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw NSError.newError("配置地址不合法")
        }
        let tempURL = try await URLSession.shared.download(from: url).0
        defer {
            do {
                try FileManager.default.removeItem(at: tempURL)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        let data = try Data(contentsOf: tempURL)

        let string = String(data: data, encoding: String.Encoding.utf8)
        let decodedData = Data(base64Encoded: string ?? "") ?? Data()
        let decodedString = String(data: decodedData, encoding: .utf8)
//        NSString(data: decodedData as! Data, encoding: NSUTF8StringEncoding)
        //https://gvgv.club/api/v1/client/subscribe?token=1ee8996d4d0bdd82a8e6428b296f15e9
//        try self.save(sourceURL: url, fileURL: tempURL)
        guard let fileData = decodedString?.data(using: String.Encoding.utf8) else {
            return
        }
        print(decodedString)
//        let vmessUrlArray = decodedString?.components(separatedBy: "\n")
//        guard let array = vmessUrlArray else {
//            return
//        }
        try save(sourceURL: url, fileData: fileData)
    }
    
    private func save(sourceURL: URL, fileURL: URL) throws {
        let id = UUID()
        let folderURL = MGConstant.configDirectory.appending(component: "\(id.uuidString)")
        let attributes = MGConfiguration.Attributes(
            alias: name.trimmingCharacters(in: .whitespacesAndNewlines),
            source: sourceURL,
            leastUpdated: Date()
        )
        try FileManager.default.createDirectory(
            at: folderURL,
            withIntermediateDirectories: true,
            attributes: [
                MGConfiguration.key: [MGConfiguration.Attributes.key: try JSONEncoder().encode(attributes)]
            ]
        )
        let destinationURL = folderURL.appending(component: "config.json")
        try FileManager.default.copyItem(at: fileURL, to: destinationURL)
    }
    private func save(sourceURL: URL, fileData: Data) throws {
        let id = UUID()
        let folderURL = MGConstant.configDirectory.appending(component: "\(id.uuidString)")
        let attributes = MGConfiguration.Attributes(
            alias: name.trimmingCharacters(in: .whitespacesAndNewlines),
            source: sourceURL,
            leastUpdated: Date()
        )
        try FileManager.default.createDirectory(
            at: folderURL,
            withIntermediateDirectories: true,
            attributes: [
                MGConfiguration.key: [MGConfiguration.Attributes.key: try JSONEncoder().encode(attributes)]
            ]
        )
        let destinationURL = folderURL.appending(component: "config.json")
        try fileData.write(to: destinationURL)
    }
}
extension String {
    ///Base64编码
    func encodBase64() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    ///Base64解码
    func decodeBase64() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
   }
