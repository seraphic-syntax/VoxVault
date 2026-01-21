import Foundation
import Speech

// MARK: - Transcription Manager
class TranscriptionManager: NSObject {
    static let shared = TranscriptionManager()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // MARK: - Request Permission
    func requestPermission(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    // MARK: - Check Permission
    func hasPermission() -> Bool {
        return SFSpeechRecognizer.authorizationStatus() == .authorized
    }
    
    // MARK: - Transcribe Recording
    func transcribe(session: RecordingSession, progress: @escaping (String) -> Void, completion: @escaping (Result<String, Error>) -> Void) {
        guard hasPermission() else {
            completion(.failure(TranscriptionError.permissionDenied))
            return
        }
        
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            completion(.failure(TranscriptionError.recognizerNotAvailable))
            return
        }
        
        transcribeSegments(session.segments, currentIndex: 0, fullTranscript: "", progress: progress, completion: completion)
    }
    
    private func transcribeSegments(_ segments: [RecordingSegment], currentIndex: Int, fullTranscript: String, progress: @escaping (String) -> Void, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard currentIndex < segments.count else {
            completion(.success(fullTranscript))
            return
        }
        
        let segment = segments[currentIndex]
        let request = SFSpeechURLRecognitionRequest(url: segment.url)
        request.shouldReportPartialResults = true
        
        speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            var isFinal = false
            var segmentTranscript = ""
            
            if let result = result {
                segmentTranscript = result.bestTranscription.formattedString
                isFinal = result.isFinal
                
                let combined = fullTranscript + (fullTranscript.isEmpty ? "" : "\n\n") + segmentTranscript
                progress(combined)
            }
            
            if error != nil || isFinal {
                let updatedTranscript = fullTranscript + (fullTranscript.isEmpty ? "" : "\n\n") + segmentTranscript
                self?.transcribeSegments(segments, currentIndex: currentIndex + 1, fullTranscript: updatedTranscript, progress: progress, completion: completion)
            }
        }
    }
    
    enum TranscriptionError: Error {
        case permissionDenied
        case recognizerNotAvailable
        case transcriptionFailed
        
        var localizedDescription: String {
            switch self {
            case .permissionDenied:
                return "Speech recognition permission is required."
            case .recognizerNotAvailable:
                return "Speech recognizer is not available."
            case .transcriptionFailed:
                return "Transcription failed. Please try again."
            }
        }
    }
}
