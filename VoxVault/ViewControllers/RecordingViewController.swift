import UIKit
import AVFoundation

// MARK: - Recording View Controller
class RecordingViewController: UIViewController {
    
    // MARK: - UI Elements
    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 75
        button.backgroundColor = .systemRed
        button.setTitle("Record", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ready to record"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00:00"
        label.font = .monospacedDigitSystemFont(ofSize: 48, weight: .light)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let storageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Stop & Save", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isHidden = true
        return button
    }()
    
    private let recordingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("View Recordings", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "gear", withConfiguration: config), for: .normal)
        return button
    }()
    
    // MARK: - Properties
    private let recordingManager = AudioRecordingManager.shared
    private var durationTimer: Timer?
    private var recordingStartTime: Date?
    
    private enum RecordingState {
        case idle
        case recording
        case paused
    }
    
    private var state: RecordingState = .idle {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "VoxVault"
        
        setupUI()
        checkForActiveRecording()
        
        AutoDeleteManager.shared.checkAndDeleteOldRecordings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStorageDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPermissions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(durationLabel)
        view.addSubview(statusLabel)
        view.addSubview(recordButton)
        view.addSubview(stopButton)
        view.addSubview(storageLabel)
        view.addSubview(recordingsButton)
        view.addSubview(settingsButton)
        
        NSLayoutConstraint.activate([
            durationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            durationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 16),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 150),
            recordButton.heightAnchor.constraint(equalToConstant: 150),
            
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 40),
            
            storageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            storageLabel.bottomAnchor.constraint(equalTo: recordingsButton.topAnchor, constant: -20),
            
            recordingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
        
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        recordingsButton.addTarget(self, action: #selector(recordingsButtonTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Permissions
    private func checkPermissions() {
        switch PermissionManager.checkMicrophonePermission() {
        case .granted:
            enableRecordingUI()
        case .denied:
            showPermissionDeniedAlert()
        case .undetermined:
            PermissionManager.requestMicrophonePermission { [weak self] granted in
                if granted {
                    self?.enableRecordingUI()
                } else {
                    self?.showPermissionDeniedAlert()
                }
            }
        @unknown default:
            showPermissionDeniedAlert()
        }
    }
    
    private func enableRecordingUI() {
        recordButton.isEnabled = true
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Microphone Access Required",
            message: "VoxVault needs microphone access to record audio journals. Please enable it in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Recording Actions
    @objc private func recordButtonTapped() {
        switch state {
        case .idle:
            startRecording()
        case .recording:
            pauseRecording()
        case .paused:
            resumeRecording()
        }
    }
    
    @objc private func stopButtonTapped() {
        stopRecording()
    }
    
    @objc private func recordingsButtonTapped() {
        let recordingsVC = RecordingsListViewController()
        navigationController?.pushViewController(recordingsVC, animated: true)
    }
    
    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    private func startRecording() {
        guard StorageManager.shared.canStartRecording() else {
            showStorageAlert()
            return
        }
        
        do {
            try recordingManager.startRecording()
            state = .recording
            recordingStartTime = Date()
            startDurationTimer()
        } catch {
            showErrorAlert(error)
        }
    }
    
    private func pauseRecording() {
        recordingManager.pauseRecording()
        state = .paused
        durationTimer?.invalidate()
    }
    
    private func resumeRecording() {
        recordingManager.resumeRecording()
        state = .recording
        startDurationTimer()
    }
    
    private func stopRecording() {
        recordingManager.stopRecording()
        state = .idle
        durationTimer?.invalidate()
        recordingStartTime = nil
        durationLabel.text = "00:00:00"
    }
    
    private func checkForActiveRecording() {
        if RecordingStateManager.shared.hasActiveRecording(),
           let startTime = RecordingStateManager.shared.getRecordingStartTime() {
            state = .recording
            recordingStartTime = startTime
            startDurationTimer()
        }
    }
    
    // MARK: - UI Updates
    private func updateUI() {
        UIView.animate(withDuration: 0.3) {
            switch self.state {
            case .idle:
                self.recordButton.setTitle("Record", for: .normal)
                self.recordButton.backgroundColor = .systemRed
                self.statusLabel.text = "Ready to record"
                self.stopButton.isHidden = true
                self.recordingsButton.isHidden = false
                
            case .recording:
                self.recordButton.setTitle("Pause", for: .normal)
                self.recordButton.backgroundColor = .systemOrange
                self.statusLabel.text = "Recording..."
                self.stopButton.isHidden = false
                self.recordingsButton.isHidden = true
                
            case .paused:
                self.recordButton.setTitle("Resume", for: .normal)
                self.recordButton.backgroundColor = .systemGreen
                self.statusLabel.text = "Paused"
                self.stopButton.isHidden = false
                self.recordingsButton.isHidden = true
            }
        }
    }
    
    private func updateStorageDisplay() {
        storageLabel.text = "Available: \(StorageManager.shared.getFormattedAvailableStorage())"
        
        if StorageManager.shared.shouldWarnAboutStorage() {
            storageLabel.textColor = .systemOrange
        } else {
            storageLabel.textColor = .secondaryLabel
        }
    }
    
    // MARK: - Duration Timer
    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDuration()
        }
    }
    
    private func updateDuration() {
        guard let startTime = recordingStartTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        durationLabel.text = formatDuration(elapsed)
        
        if Int(elapsed) % 10 == 0 {
            updateStorageDisplay()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - Alerts
    private func showStorageAlert() {
        let alert = UIAlertController(
            title: "Insufficient Storage",
            message: "Not enough storage space to start recording. Please free up space and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(_ error: Error) {
        let message = (error as? RecordingError)?.userMessage ?? error.localizedDescription
        let alert = UIAlertController(
            title: "Recording Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
