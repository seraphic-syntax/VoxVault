import Foundation
import AVFoundation

// MARK: - Settings Manager
class SettingsManager {
    static let shared = SettingsManager()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let segmentDuration = "segmentDuration"
        static let audioQuality = "audioQuality"
        static let autoDeleteDays = "autoDeleteDays"
        static let exportFormat = "exportFormat"
        static let iCloudSyncEnabled = "iCloudSyncEnabled"
        static let playbackSpeed = "playbackSpeed"
    }
    
    // MARK: - Segment Duration
    var segmentDuration: TimeInterval {
        get {
            let duration = userDefaults.double(forKey: Keys.segmentDuration)
            return duration > 0 ? duration : 600.0
        }
        set {
            userDefaults.set(newValue, forKey: Keys.segmentDuration)
        }
    }
    
    static let presetDurations: [(title: String, duration: TimeInterval)] = [
        ("5 minutes", 300),
        ("10 minutes", 600),
        ("15 minutes", 900),
        ("30 minutes", 1800),
        ("1 hour", 3600)
    ]
    
    func getSegmentDurationTitle() -> String {
        let duration = segmentDuration
        for preset in SettingsManager.presetDurations {
            if preset.duration == duration {
                return preset.title
            }
        }
        return "\(Int(duration / 60)) minutes"
    }
    
    // MARK: - Audio Quality
    enum AudioQuality: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var settings: [String: Any] {
            switch self {
            case .low:
                return [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 22050.0,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue,
                    AVEncoderBitRateKey: 32000
                ]
            case .medium:
                return [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100.0,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
                    AVEncoderBitRateKey: 64000
                ]
            case .high:
                return [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100.0,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                    AVEncoderBitRateKey: 128000
                ]
            }
        }
        
        var description: String {
            switch self {
            case .low:
                return "32 kbps - Best battery life"
            case .medium:
                return "64 kbps - Balanced"
            case .high:
                return "128 kbps - Best quality"
            }
        }
    }
    
    var audioQuality: AudioQuality {
        get {
            guard let rawValue = userDefaults.string(forKey: Keys.audioQuality),
                  let quality = AudioQuality(rawValue: rawValue) else {
                return .medium
            }
            return quality
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.audioQuality)
        }
    }
    
    // MARK: - Auto-Delete
    var autoDeleteDays: Int {
        get {
            let days = userDefaults.integer(forKey: Keys.autoDeleteDays)
            return days > 0 ? days : 0
        }
        set {
            userDefaults.set(newValue, forKey: Keys.autoDeleteDays)
        }
    }
    
    static let autoDeleteOptions: [(title: String, days: Int)] = [
        ("Never", 0),
        ("After 7 days", 7),
        ("After 14 days", 14),
        ("After 30 days", 30),
        ("After 60 days", 60),
        ("After 90 days", 90)
    ]
    
    func getAutoDeleteTitle() -> String {
        let days = autoDeleteDays
        for option in SettingsManager.autoDeleteOptions {
            if option.days == days {
                return option.title
            }
        }
        return "After \(days) days"
    }
    
    // MARK: - Export Format
    enum ExportFormat: String {
        case m4a = "M4A"
        case mp3 = "MP3"
        case wav = "WAV"
        
        var description: String {
            switch self {
            case .m4a:
                return "M4A (AAC) - Small file size"
            case .mp3:
                return "MP3 - Universal compatibility"
            case .wav:
                return "WAV - Uncompressed"
            }
        }
        
        var fileExtension: String {
            return rawValue.lowercased()
        }
    }
    
    var exportFormat: ExportFormat {
        get {
            guard let rawValue = userDefaults.string(forKey: Keys.exportFormat),
                  let format = ExportFormat(rawValue: rawValue) else {
                return .m4a
            }
            return format
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.exportFormat)
        }
    }
    
    // MARK: - iCloud Sync
    var iCloudSyncEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.iCloudSyncEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.iCloudSyncEnabled)
        }
    }
    
    // MARK: - Playback Speed
    var playbackSpeed: Float {
        get {
            let speed = userDefaults.float(forKey: Keys.playbackSpeed)
            return speed > 0 ? speed : 1.0
        }
        set {
            userDefaults.set(newValue, forKey: Keys.playbackSpeed)
        }
    }
    
    static let playbackSpeeds: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
}
