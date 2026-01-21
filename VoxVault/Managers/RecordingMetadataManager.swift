import Foundation

// MARK: - Recording Metadata Manager
class RecordingMetadataManager {
    static let shared = RecordingMetadataManager()
    
    private let userDefaults = UserDefaults.standard
    private let metadataKey = "recordingMetadata"
    
    private var metadata: [String: SessionMetadata] {
        get {
            guard let data = userDefaults.data(forKey: metadataKey),
                  let decoded = try? JSONDecoder().decode([String: SessionMetadata].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                userDefaults.set(encoded, forKey: metadataKey)
            }
        }
    }
    
    // MARK: - Get Metadata
    func getMetadata(for sessionID: String) -> SessionMetadata {
        return metadata[sessionID] ?? SessionMetadata(sessionID: sessionID)
    }
    
    // MARK: - Update Metadata
    func updateMetadata(for sessionID: String, update: (inout SessionMetadata) -> Void) {
        var meta = getMetadata(for: sessionID)
        update(&meta)
        var allMetadata = metadata
        allMetadata[sessionID] = meta
        metadata = allMetadata
    }
    
    // MARK: - Delete Metadata
    func deleteMetadata(for sessionID: String) {
        var allMetadata = metadata
        allMetadata.removeValue(forKey: sessionID)
        metadata = allMetadata
    }
    
    // MARK: - Search
    func searchRecordings(query: String, in sessions: [RecordingSession]) -> [RecordingSession] {
        let lowercased = query.lowercased()
        
        return sessions.filter { session in
            let meta = getMetadata(for: session.sessionID)
            
            if let name = meta.customName?.lowercased(), name.contains(lowercased) {
                return true
            }
            
            if meta.tags.contains(where: { $0.lowercased().contains(lowercased) }) {
                return true
            }
            
            if let category = meta.category?.lowercased(), category.contains(lowercased) {
                return true
            }
            
            if let transcription = meta.transcription?.lowercased(), transcription.contains(lowercased) {
                return true
            }
            
            return false
        }
    }
    
    // MARK: - Filter by Category
    func filterByCategory(_ category: String, in sessions: [RecordingSession]) -> [RecordingSession] {
        return sessions.filter { session in
            let meta = getMetadata(for: session.sessionID)
            return meta.category == category
        }
    }
    
    // MARK: - Get All Categories
    func getAllCategories() -> [String] {
        let categories = metadata.values.compactMap { $0.category }
        return Array(Set(categories)).sorted()
    }
    
    // MARK: - Get All Tags
    func getAllTags() -> [String] {
        let tags = metadata.values.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }
    
    // MARK: - Favorites
    func getFavorites(from sessions: [RecordingSession]) -> [RecordingSession] {
        return sessions.filter { session in
            let meta = getMetadata(for: session.sessionID)
            return meta.isFavorite
        }
    }
}
