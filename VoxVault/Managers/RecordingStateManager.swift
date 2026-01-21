import Foundation

// MARK: - Recording State Manager
class RecordingStateManager {
    static let shared = RecordingStateManager()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let currentSessionID = "currentSessionID"
        static let currentSegment = "currentSegment"
        static let recordingStartTime = "recordingStartTime"
        static let isRecording = "isRecording"
    }
    
    func saveRecordingState(sessionID: String, segment: Int, startTime: Date) {
        userDefaults.set(sessionID, forKey: Keys.currentSessionID)
        userDefaults.set(segment, forKey: Keys.currentSegment)
        userDefaults.set(startTime, forKey: Keys.recordingStartTime)
        userDefaults.set(true, forKey: Keys.isRecording)
    }
    
    func clearRecordingState() {
        userDefaults.removeObject(forKey: Keys.currentSessionID)
        userDefaults.removeObject(forKey: Keys.currentSegment)
        userDefaults.removeObject(forKey: Keys.recordingStartTime)
        userDefaults.set(false, forKey: Keys.isRecording)
    }
    
    func hasActiveRecording() -> Bool {
        return userDefaults.bool(forKey: Keys.isRecording)
    }
    
    func getRecordingStartTime() -> Date? {
        return userDefaults.object(forKey: Keys.recordingStartTime) as? Date
    }
}
