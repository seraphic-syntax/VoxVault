import Foundation
import AVFoundation

// MARK: - Recording File Manager
class RecordingFileManager {
    static let shared = RecordingFileManager()
    
    private let fileManager = FileManager.default
    private var recordingsDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath
            .appendingPathComponent("VoxVault")
            .appendingPathComponent("Recordings")
    }
    
    init() {
        try? setup()
    }
    
    func setup() throws {
        try fileManager.createDirectory(
            at: recordingsDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
    
    func getRecordingURL(sessionID: String, segment: Int) -> URL {
        return recordingsDirectory
            .appendingPathComponent("\(sessionID)_segment_\(segment)")
            .appendingPathExtension("m4a")
    }
    
    func generateSessionID() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay, 
                                   .withTime, .withColonSeparatorInTime]
        return formatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")
    }
    
    // MARK: - Fetch All Recordings
    func fetchAllRecordings() throws -> [RecordingSession] {
        let files = try fileManager.contentsOfDirectory(
            at: recordingsDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .creationDateKey],
            options: [.skipsHiddenFiles]
        )
        
        var sessions: [String: [RecordingSegment]] = [:]
        
        for fileURL in files {
            guard let sessionID = extractSessionID(from: fileURL),
                  let segmentNum = extractSegmentNumber(from: fileURL) else {
                continue
            }
            
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            let duration = getAudioDuration(url: fileURL)
            
            let segment = RecordingSegment(
                url: fileURL,
                segment: segmentNum,
                duration: duration,
                fileSize: fileSize
            )
            
            sessions[sessionID, default: []].append(segment)
        }
        
        return sessions.map { sessionID, segments in
            RecordingSession(
                sessionID: sessionID,
                segments: segments.sorted { $0.segment < $1.segment }
            )
        }.sorted { $0.date > $1.date }
    }
    
    private func extractSessionID(from url: URL) -> String? {
        let filename = url.deletingPathExtension().lastPathComponent
        let components = filename.components(separatedBy: "_segment_")
        return components.first
    }
    
    private func extractSegmentNumber(from url: URL) -> Int? {
        let filename = url.deletingPathExtension().lastPathComponent
        let components = filename.components(separatedBy: "_segment_")
        guard components.count == 2 else { return nil }
        return Int(components[1])
    }
    
    private func getAudioDuration(url: URL) -> TimeInterval {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }
}
