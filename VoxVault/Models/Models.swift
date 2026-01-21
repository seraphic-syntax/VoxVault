import Foundation
import AVFoundation

// MARK: - Recording Error Types
enum RecordingError: Error {
    case permissionDenied
    case audioSessionFailed
    case insufficientStorage
    case fileCreationFailed
    case recordingFailed
    
    var userMessage: String {
        switch self {
        case .permissionDenied:
            return "Microphone access is required. Please enable in Settings."
        case .audioSessionFailed:
            return "Could not initialize audio system. Please restart the app."
        case .insufficientStorage:
            return "Not enough storage space. Please free up space and try again."
        case .fileCreationFailed:
            return "Could not create recording file. Please check storage."
        case .recordingFailed:
            return "Recording failed. Please try again."
        }
    }
}

// MARK: - Recording Session
struct RecordingSession {
    let sessionID: String
    let segments: [RecordingSegment]
    var tags: [String]
    var customName: String?
    var isFavorite: Bool
    var category: String?
    
    var totalDuration: TimeInterval {
        segments.reduce(0) { $0 + $1.duration }
    }
    
    var date: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime, .withColonSeparatorInTime]
        let normalized = sessionID.replacingOccurrences(of: "-", with: ":")
        return formatter.date(from: normalized) ?? Date()
    }
    
    var totalSize: Int64 {
        segments.reduce(0) { $0 + $1.fileSize }
    }
    
    var displayName: String {
        if let custom = customName, !custom.isEmpty {
            return custom
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    init(sessionID: String, segments: [RecordingSegment], tags: [String] = [], customName: String? = nil, isFavorite: Bool = false, category: String? = nil) {
        self.sessionID = sessionID
        self.segments = segments
        self.tags = tags
        self.customName = customName
        self.isFavorite = isFavorite
        self.category = category
    }
}

// MARK: - Recording Segment
struct RecordingSegment {
    let url: URL
    let segment: Int
    let duration: TimeInterval
    let fileSize: Int64
}

// MARK: - Session Metadata
struct SessionMetadata: Codable {
    let sessionID: String
    var customName: String?
    var tags: [String]
    var isFavorite: Bool
    var category: String?
    var transcription: String?
    var createdAt: Date
    var lastModified: Date
    
    init(sessionID: String, customName: String? = nil, tags: [String] = [], isFavorite: Bool = false, category: String? = nil, transcription: String? = nil) {
        self.sessionID = sessionID
        self.customName = customName
        self.tags = tags
        self.isFavorite = isFavorite
        self.category = category
        self.transcription = transcription
        self.createdAt = Date()
        self.lastModified = Date()
    }
}
