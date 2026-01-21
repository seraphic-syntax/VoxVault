import Foundation

// MARK: - Auto-Delete Manager
class AutoDeleteManager {
    static let shared = AutoDeleteManager()
    
    func checkAndDeleteOldRecordings() {
        let autoDeleteDays = SettingsManager.shared.autoDeleteDays
        guard autoDeleteDays > 0 else { return }
        
        do {
            let sessions = try RecordingFileManager.shared.fetchAllRecordings()
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -autoDeleteDays, to: Date())!
            
            for session in sessions {
                if session.date < cutoffDate {
                    try deleteSession(session)
                    print("Auto-deleted recording from \(session.date)")
                }
            }
        } catch {
            print("Auto-delete error: \(error)")
        }
    }
    
    private func deleteSession(_ session: RecordingSession) throws {
        for segment in session.segments {
            try FileManager.default.removeItem(at: segment.url)
        }
    }
    
    func getOldRecordingsCount() throws -> Int {
        let autoDeleteDays = SettingsManager.shared.autoDeleteDays
        guard autoDeleteDays > 0 else { return 0 }
        
        let sessions = try RecordingFileManager.shared.fetchAllRecordings()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -autoDeleteDays, to: Date())!
        
        return sessions.filter { $0.date < cutoffDate }.count
    }
}
