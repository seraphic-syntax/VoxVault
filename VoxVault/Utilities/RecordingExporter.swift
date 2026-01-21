import Foundation
import AVFoundation

// MARK: - Recording Exporter
class RecordingExporter {
    
    enum ExportError: Error {
        case noSegments
        case exportFailed
    }
    
    func combineAndExport(session: RecordingSession, format: SettingsManager.ExportFormat) throws -> URL {
        guard !session.segments.isEmpty else { throw ExportError.noSegments }
        
        if session.segments.count == 1 && format == .m4a {
            return try copySegment(session.segments[0], session: session)
        }
        
        let combinedURL = try combineSegments(session.segments)
        return try renameCombinedFile(combinedURL, session: session, format: format)
    }
    
    private func copySegment(_ segment: RecordingSegment, session: RecordingSession) throws -> URL {
        let exportDir = getExportDirectory()
        let fileName = generateFileName(for: session, format: .m4a)
        let destinationURL = exportDir.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.copyItem(at: segment.url, to: destinationURL)
        return destinationURL
    }
    
    private func combineSegments(_ segments: [RecordingSegment]) throws -> URL {
        let composition = AVMutableComposition()
        
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            throw ExportError.exportFailed
        }
        
        var currentTime = CMTime.zero
        
        for segment in segments.sorted(by: { $0.segment < $1.segment }) {
            let asset = AVURLAsset(url: segment.url)
            guard let assetTrack = asset.tracks(withMediaType: .audio).first else { continue }
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            try audioTrack.insertTimeRange(timeRange, of: assetTrack, at: currentTime)
            currentTime = CMTimeAdd(currentTime, asset.duration)
        }
        
        return try exportComposition(composition)
    }
    
    private func exportComposition(_ composition: AVMutableComposition) throws -> URL {
        let exportDir = getExportDirectory()
        let tempURL = exportDir.appendingPathComponent("temp_combined.m4a")
        try? FileManager.default.removeItem(at: tempURL)
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) else {
            throw ExportError.exportFailed
        }
        
        exportSession.outputURL = tempURL
        exportSession.outputFileType = .m4a
        
        let semaphore = DispatchSemaphore(value: 0)
        var exportError: Error?
        
        exportSession.exportAsynchronously {
            if exportSession.status != .completed {
                exportError = exportSession.error ?? ExportError.exportFailed
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        if let error = exportError { throw error }
        return tempURL
    }
    
    private func renameCombinedFile(_ sourceURL: URL, session: RecordingSession, format: SettingsManager.ExportFormat) throws -> URL {
        let exportDir = getExportDirectory()
        let fileName = generateFileName(for: session, format: format)
        let destinationURL = exportDir.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }
    
    private func getExportDirectory() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportDir = documentsPath.appendingPathComponent("VoxVault").appendingPathComponent("Exports")
        try? FileManager.default.createDirectory(at: exportDir, withIntermediateDirectories: true)
        return exportDir
    }
    
    private func generateFileName(for session: RecordingSession, format: SettingsManager.ExportFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return "VoxVault_\(formatter.string(from: session.date)).\(format.fileExtension)"
    }
}
