import Foundation
import CloudKit

// MARK: - iCloud Sync Manager
class iCloudSyncManager {
    static let shared = iCloudSyncManager()
    
    private let container: CKContainer
    private let database: CKDatabase
    private var isAvailable: Bool = false
    
    private init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
        checkAccountStatus()
    }
    
    private func checkAccountStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.isAvailable = (status == .available)
            }
        }
    }
    
    func isICloudAvailable() -> Bool {
        return isAvailable && SettingsManager.shared.iCloudSyncEnabled
    }
    
    func uploadRecording(session: RecordingSession, completion: @escaping (Result<Void, Error>) -> Void) {
        guard isICloudAvailable() else {
            completion(.failure(SyncError.iCloudNotAvailable))
            return
        }
        
        let record = CKRecord(recordType: "Recording")
        record["sessionID"] = session.sessionID as CKRecordValue
        
        let metadata = RecordingMetadataManager.shared.getMetadata(for: session.sessionID)
        record["customName"] = metadata.customName as CKRecordValue?
        record["tags"] = metadata.tags as CKRecordValue
        record["isFavorite"] = metadata.isFavorite as CKRecordValue
        record["category"] = metadata.category as CKRecordValue?
        record["transcription"] = metadata.transcription as CKRecordValue?
        
        var assets: [CKAsset] = []
        for segment in session.segments {
            let asset = CKAsset(fileURL: segment.url)
            assets.append(asset)
        }
        record["segments"] = assets as CKRecordValue
        
        database.save(record) { savedRecord, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func downloadRecordings(completion: @escaping (Result<[RecordingSession], Error>) -> Void) {
        guard isICloudAvailable() else {
            completion(.failure(SyncError.iCloudNotAvailable))
            return
        }
        
        let query = CKQuery(recordType: "Recording", predicate: NSPredicate(value: true))
        
        database.fetch(withQuery: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success([]))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func syncAll(completion: @escaping (Result<Void, Error>) -> Void) {
        guard isICloudAvailable() else {
            completion(.failure(SyncError.iCloudNotAvailable))
            return
        }
        completion(.success(()))
    }
    
    enum SyncError: Error {
        case iCloudNotAvailable
        case uploadFailed
        case downloadFailed
        
        var localizedDescription: String {
            switch self {
            case .iCloudNotAvailable:
                return "iCloud is not available."
            case .uploadFailed:
                return "Failed to upload recording."
            case .downloadFailed:
                return "Failed to download recordings."
            }
        }
    }
}
