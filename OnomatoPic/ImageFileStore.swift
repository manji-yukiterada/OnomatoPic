import Foundation

enum ImageFileStore {
    
    static var directoryURL: URL {
        FileManager.default
            .urls(for: .applicationSupportDirectory,
                  in: .userDomainMask)[0]
            .appendingPathComponent("OnomatoPicImages",
                                    isDirectory: true)
    }
    
    static func save(
        _ imageData: Data,
        fileName: String = "photo-\(UUID().uuidString).jpg"
    ) throws -> String {
        
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        
        let fileURL = directoryURL
            .appendingPathComponent(fileName)
        
        try imageData.write(to: fileURL, options: .atomic)
        
        return fileName
    }
    
    static func load(fileName: String) -> Data? {
        let fileURL = directoryURL
            .appendingPathComponent(fileName)
        
        return try? Data(contentsOf: fileURL)
    }
}
