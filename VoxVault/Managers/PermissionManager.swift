import Foundation
import AVFoundation

// MARK: - Permission Manager
class PermissionManager {
    static func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    static func checkMicrophonePermission() -> AVAudioSession.RecordPermission {
        return AVAudioSession.sharedInstance().recordPermission
    }
}
