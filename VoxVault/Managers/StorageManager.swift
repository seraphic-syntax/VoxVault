import Foundation

// MARK: - Storage Manager
class StorageManager {
    static let shared = StorageManager()
    
    private let minimumStorageThresholdMB: Int64 = 500
    private let warningThresholdMB: Int64 = 1000
    
    func getAvailableStorage() -> Int64? {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: path)
            if let freeSpace = attributes[.systemFreeSize] as? Int64 {
                return freeSpace
            }
        } catch {
            print("Error getting storage: \(error)")
        }
        return nil
    }
    
    func getFormattedAvailableStorage() -> String {
        guard let bytes = getAvailableStorage() else {
            return "Unknown"
        }
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    func shouldWarnAboutStorage() -> Bool {
        guard let available = getAvailableStorage() else { return false }
        return available < (warningThresholdMB * 1024 * 1024)
    }
    
    func canStartRecording() -> Bool {
        guard let available = getAvailableStorage() else { return false }
        return available > (minimumStorageThresholdMB * 1024 * 1024)
    }
}
