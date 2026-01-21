import UIKit
import AVFoundation

// MARK: - Playback View Controller
class PlaybackViewController: UIViewController {
    
    private let session: RecordingSession
    private let playbackManager = AudioPlaybackManager.shared
    private var progressTimer: Timer?
    private var isPlaying = false
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let segmentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.text = "00:00"
        return label
    }()
    
    private let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        label.text = "00:00"
        return label
    }()
    
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        return slider
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 60)
        button.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
        return button
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        button.setImage(UIImage(systemName: "backward.fill", withConfiguration: config), for: .normal)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        button.setImage(UIImage(systemName: "forward.fill", withConfiguration: config), for: .normal)
        return button
    }()
    
    private let speedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("1.0x", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    init(session: RecordingSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Playback"
        setupUI()
        configureSession()
        playbackManager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            playbackManager.stop()
            progressTimer?.invalidate()
        }
    }
    
    private func setupUI() {
        view.addSubview(dateLabel)
        view.addSubview(segmentLabel)
        view.addSubview(currentTimeLabel)
        view.addSubview(remainingTimeLabel)
        view.addSubview(progressSlider)
        view.addSubview(playPauseButton)
        view.addSubview(previousButton)
        view.addSubview(nextButton)
        view.addSubview(speedButton)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            segmentLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            segmentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            currentTimeLabel.topAnchor.constraint(equalTo: segmentLabel.bottomAnchor, constant: 60),
            currentTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            remainingTimeLabel.topAnchor.constraint(equalTo: currentTimeLabel.topAnchor),
            remainingTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            progressSlider.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 8),
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 60),
            playPauseButton.widthAnchor.constraint(equalToConstant: 80),
            playPauseButton.heightAnchor.constraint(equalToConstant: 80),
            
            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -40),
            
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 40),
            
            speedButton.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor, constant: 30),
            speedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        speedButton.addTarget(self, action: #selector(speedTapped), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    private func configureSession() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: session.date)
        segmentLabel.text = "\(session.segments.count) segment(s)"
        progressSlider.maximumValue = Float(session.totalDuration)
        updateSpeedButton()
    }
    
    @objc private func playPauseTapped() {
        if isPlaying {
            playbackManager.pause()
        } else {
            if playbackManager.currentTime == 0 {
                playbackManager.playSession(session)
            } else {
                playbackManager.resume()
            }
        }
    }
    
    @objc private func previousTapped() {
        playbackManager.previousSegment()
    }
    
    @objc private func nextTapped() {
        playbackManager.nextSegment()
    }
    
    @objc private func sliderChanged() {
        playbackManager.seek(to: TimeInterval(progressSlider.value))
    }
    
    @objc private func speedTapped() {
        let alert = UIAlertController(title: "Playback Speed", message: nil, preferredStyle: .actionSheet)
        for speed in SettingsManager.playbackSpeeds {
            alert.addAction(UIAlertAction(title: "\(speed)x", style: .default) { [weak self] _ in
                SettingsManager.shared.playbackSpeed = speed
                self?.playbackManager.playbackSpeed = speed
                self?.updateSpeedButton()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = speedButton
            popover.sourceRect = speedButton.bounds
        }
        present(alert, animated: true)
    }
    
    private func updateSpeedButton() {
        speedButton.setTitle("\(SettingsManager.shared.playbackSpeed)x", for: .normal)
    }
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let current = self.playbackManager.currentTime
            let duration = self.playbackManager.duration
            self.progressSlider.value = Float(current)
            self.currentTimeLabel.text = self.formatTime(current)
            self.remainingTimeLabel.text = "-\(self.formatTime(duration - current))"
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let m = Int(time) / 60
        let s = Int(time) % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func updatePlayPauseButton(playing: Bool) {
        isPlaying = playing
        let config = UIImage.SymbolConfiguration(pointSize: 60)
        let name = playing ? "pause.circle.fill" : "play.circle.fill"
        playPauseButton.setImage(UIImage(systemName: name, withConfiguration: config), for: .normal)
    }
}

extension PlaybackViewController: AudioPlaybackDelegate {
    func playbackDidStart() {
        updatePlayPauseButton(playing: true)
        if progressTimer == nil { startProgressTimer() }
    }
    
    func playbackDidPause() {
        updatePlayPauseButton(playing: false)
    }
    
    func playbackDidStop() {
        updatePlayPauseButton(playing: false)
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    func playbackDidFinish() {
        updatePlayPauseButton(playing: false)
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    func playbackDidEncounterError(_ error: Error) {
        updatePlayPauseButton(playing: false)
        progressTimer?.invalidate()
    }
}
