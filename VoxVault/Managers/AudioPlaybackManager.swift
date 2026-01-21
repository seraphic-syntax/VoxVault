import Foundation
import AVFoundation

// MARK: - Audio Playback Manager
class AudioPlaybackManager: NSObject {
    static let shared = AudioPlaybackManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var currentSession: RecordingSession?
    private var currentSegmentIndex: Int = 0
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    var currentTime: TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    
    var duration: TimeInterval {
        return audioPlayer?.duration ?? 0
    }
    
    var playbackSpeed: Float {
        get {
            return audioPlayer?.rate ?? 1.0
        }
        set {
            audioPlayer?.rate = newValue
            audioPlayer?.enableRate = true
        }
    }
    
    weak var delegate: AudioPlaybackDelegate?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Playback Control
    func playSession(_ session: RecordingSession, from segmentIndex: Int = 0) {
        currentSession = session
        currentSegmentIndex = segmentIndex
        playCurrentSegment()
    }
    
    private func playCurrentSegment() {
        guard let session = currentSession,
              currentSegmentIndex < session.segments.count else {
            delegate?.playbackDidFinish()
            return
        }
        
        let segment = session.segments[currentSegmentIndex]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: segment.url)
            audioPlayer?.delegate = self
            audioPlayer?.enableRate = true
            audioPlayer?.rate = SettingsManager.shared.playbackSpeed
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            delegate?.playbackDidStart()
        } catch {
            print("Playback error: \(error)")
            delegate?.playbackDidEncounterError(error)
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        delegate?.playbackDidPause()
    }
    
    func resume() {
        audioPlayer?.play()
        delegate?.playbackDidStart()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentSession = nil
        currentSegmentIndex = 0
        delegate?.playbackDidStop()
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
    
    func getCurrentSegmentInfo() -> (index: Int, total: Int)? {
        guard let session = currentSession else { return nil }
        return (currentSegmentIndex, session.segments.count)
    }
    
    func nextSegment() {
        guard let session = currentSession else { return }
        if currentSegmentIndex < session.segments.count - 1 {
            audioPlayer?.stop()
            currentSegmentIndex += 1
            playCurrentSegment()
        }
    }
    
    func previousSegment() {
        if currentTime > 3.0 {
            seek(to: 0)
        } else if currentSegmentIndex > 0 {
            audioPlayer?.stop()
            currentSegmentIndex -= 1
            playCurrentSegment()
        } else {
            seek(to: 0)
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlaybackManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag, let session = currentSession else {
            delegate?.playbackDidFinish()
            return
        }
        
        currentSegmentIndex += 1
        if currentSegmentIndex < session.segments.count {
            playCurrentSegment()
        } else {
            delegate?.playbackDidFinish()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            delegate?.playbackDidEncounterError(error)
        }
    }
}

// MARK: - Playback Delegate Protocol
protocol AudioPlaybackDelegate: AnyObject {
    func playbackDidStart()
    func playbackDidPause()
    func playbackDidStop()
    func playbackDidFinish()
    func playbackDidEncounterError(_ error: Error)
}
