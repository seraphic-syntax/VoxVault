import Foundation
import AVFoundation

// MARK: - Audio Recording Manager
class AudioRecordingManager: NSObject {
    static let shared = AudioRecordingManager()
    
    private var audioRecorder: AVAudioRecorder?
    private var currentSessionID: String?
    private var segmentCounter: Int = 0
    private var segmentationTimer: DispatchSourceTimer?
    private let audioSession = AVAudioSession.sharedInstance()
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    var currentSession: String? {
        return currentSessionID
    }
    
    private override init() {
        super.init()
        setupInterruptionHandling()
    }
    
    // MARK: - Audio Session Configuration
    func configureAudioSession() throws {
        try audioSession.setCategory(.record, mode: .default, options: [])
        try audioSession.setActive(true)
    }
    
    // MARK: - Recording Settings
    private func getAudioSettings() -> [String: Any] {
        return SettingsManager.shared.audioQuality.settings
    }
    
    // MARK: - Start Recording
    func startRecording() throws {
        guard StorageManager.shared.canStartRecording() else {
            throw RecordingError.insufficientStorage
        }
        
        try configureAudioSession()
        
        currentSessionID = RecordingFileManager.shared.generateSessionID()
        segmentCounter = 0
        
        let audioURL = RecordingFileManager.shared.getRecordingURL(
            sessionID: currentSessionID!,
            segment: segmentCounter
        )
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: getAudioSettings())
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            RecordingStateManager.shared.saveRecordingState(
                sessionID: currentSessionID!,
                segment: segmentCounter,
                startTime: Date()
            )
            
            scheduleSegmentation()
        } catch {
            throw RecordingError.recordingFailed
        }
    }
    
    // MARK: - Pause Recording
    func pauseRecording() {
        audioRecorder?.pause()
    }
    
    // MARK: - Resume Recording
    func resumeRecording() {
        audioRecorder?.record()
    }
    
    // MARK: - Stop Recording
    func stopRecording() {
        audioRecorder?.stop()
        segmentationTimer?.cancel()
        segmentationTimer = nil
        RecordingStateManager.shared.clearRecordingState()
        currentSessionID = nil
        segmentCounter = 0
    }
    
    // MARK: - Auto-Segmentation
    private func scheduleSegmentation() {
        let duration = SettingsManager.shared.segmentDuration
        let queue = DispatchQueue(label: "com.voxvault.segmentation")
        segmentationTimer = DispatchSource.makeTimerSource(queue: queue)
        segmentationTimer?.schedule(
            deadline: .now() + duration,
            repeating: duration,
            leeway: .seconds(1)
        )
        segmentationTimer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.segmentRecording()
            }
        }
        segmentationTimer?.resume()
    }
    
    private func segmentRecording() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        
        recorder.stop()
        segmentCounter += 1
        
        let nextURL = RecordingFileManager.shared.getRecordingURL(
            sessionID: currentSessionID!,
            segment: segmentCounter
        )
        
        do {
            audioRecorder = try AVAudioRecorder(url: nextURL, settings: getAudioSettings())
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            RecordingStateManager.shared.saveRecordingState(
                sessionID: currentSessionID!,
                segment: segmentCounter,
                startTime: Date()
            )
        } catch {
            print("Segmentation error: \(error)")
        }
    }
    
    // MARK: - Interruption Handling
    private func setupInterruptionHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            pauseRecording()
            
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                resumeRecording()
            }
            
        @unknown default:
            break
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecordingManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording finished unsuccessfully")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Recording encode error: \(error)")
        }
    }
}
