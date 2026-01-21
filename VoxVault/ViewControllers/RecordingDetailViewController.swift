import UIKit

// MARK: - Recording Detail View Controller
class RecordingDetailViewController: UITableViewController {
    
    private let session: RecordingSession
    private var metadata: SessionMetadata
    
    private enum Section: Int, CaseIterable {
        case info
        case customization
        case transcription
        case actions
        
        var title: String? {
            switch self {
            case .info: return "Information"
            case .customization: return "Organize"
            case .transcription: return "Transcription"
            case .actions: return "Actions"
            }
        }
    }
    
    init(session: RecordingSession) {
        self.session = session
        self.metadata = RecordingMetadataManager.shared.getMetadata(for: session.sessionID)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recording Details"
        view.backgroundColor = .systemGroupedBackground
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(DetailCell.self, forCellReuseIdentifier: "DetailCell")
    }
    
    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .info: return 4
        case .customization: return 4
        case .transcription: return metadata.transcription == nil ? 1 : 2
        case .actions: return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
        case .info:
            return configureInfoCell(at: indexPath)
        case .customization:
            return configureCustomizationCell(at: indexPath)
        case .transcription:
            return configureTranscriptionCell(at: indexPath)
        case .actions:
            return configureActionCell(at: indexPath)
        }
    }
    
    private func configureInfoCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        switch indexPath.row {
        case 0:
            cell.configure(title: "Date", value: dateFormatter.string(from: session.date))
        case 1:
            cell.configure(title: "Duration", value: formatDuration(session.totalDuration))
        case 2:
            cell.configure(title: "Segments", value: "\(session.segments.count)")
        case 3:
            let sizeFormatter = ByteCountFormatter()
            cell.configure(title: "File Size", value: sizeFormatter.string(fromByteCount: session.totalSize))
        default:
            break
        }
        
        return cell
    }
    
    private func configureCustomizationCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "CustomizationCell")
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Custom Name"
            cell.detailTextLabel?.text = metadata.customName ?? "Not set"
        case 1:
            cell.textLabel?.text = "Category"
            cell.detailTextLabel?.text = metadata.category ?? "None"
        case 2:
            cell.textLabel?.text = "Tags"
            cell.detailTextLabel?.text = metadata.tags.isEmpty ? "None" : metadata.tags.joined(separator: ", ")
        case 3:
            cell.textLabel?.text = "Favorite"
            cell.accessoryType = metadata.isFavorite ? .checkmark : .none
        default:
            break
        }
        
        return cell
    }
    
    private func configureTranscriptionCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.textColor = .label
        
        if metadata.transcription == nil {
            cell.textLabel?.text = "Generate Transcription"
            cell.textLabel?.textColor = .systemBlue
            cell.accessoryType = .disclosureIndicator
        } else {
            if indexPath.row == 0 {
                cell.textLabel?.text = "View Transcription"
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.textLabel?.text = "Delete Transcription"
                cell.textLabel?.textColor = .systemRed
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    private func configureActionCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.textColor = .label
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Play Recording"
        case 1:
            cell.textLabel?.text = "Export"
        case 2:
            cell.textLabel?.text = "Share"
        case 3:
            cell.textLabel?.text = "Delete"
            cell.textLabel?.textColor = .systemRed
            cell.accessoryType = .none
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let sectionType = Section(rawValue: indexPath.section) else { return }
        
        switch sectionType {
        case .info:
            break
        case .customization:
            handleCustomizationTap(at: indexPath)
        case .transcription:
            handleTranscriptionTap(at: indexPath)
        case .actions:
            handleActionTap(at: indexPath)
        }
    }
    
    private func handleCustomizationTap(at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            showNameEditor()
        case 1:
            showCategoryPicker()
        case 2:
            showTagEditor()
        case 3:
            toggleFavorite()
        default:
            break
        }
    }
    
    private func handleTranscriptionTap(at indexPath: IndexPath) {
        if metadata.transcription == nil {
            generateTranscription()
        } else {
            if indexPath.row == 0 {
                showTranscription()
            } else {
                deleteTranscription()
            }
        }
    }
    
    private func handleActionTap(at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            playRecording()
        case 1:
            exportRecording()
        case 2:
            shareRecording()
        case 3:
            deleteRecording()
        default:
            break
        }
    }
    
    // MARK: - Customization Actions
    private func showNameEditor() {
        let alert = UIAlertController(title: "Custom Name", message: "Give this recording a memorable name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Recording name"
            textField.text = self.metadata.customName
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let name = alert.textFields?.first?.text
            RecordingMetadataManager.shared.updateMetadata(for: self.session.sessionID) { meta in
                meta.customName = name?.isEmpty == true ? nil : name
            }
            self.metadata = RecordingMetadataManager.shared.getMetadata(for: self.session.sessionID)
            self.tableView.reloadData()
        })
        present(alert, animated: true)
    }
    
    private func showCategoryPicker() {
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        
        for category in CategoryManager.shared.allCategories {
            alert.addAction(UIAlertAction(title: category, style: .default) { [weak self] _ in
                guard let self = self else { return }
                RecordingMetadataManager.shared.updateMetadata(for: self.session.sessionID) { meta in
                    meta.category = category
                }
                self.metadata = RecordingMetadataManager.shared.getMetadata(for: self.session.sessionID)
                self.tableView.reloadData()
            })
        }
        
        if metadata.category != nil {
            alert.addAction(UIAlertAction(title: "Remove Category", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                RecordingMetadataManager.shared.updateMetadata(for: self.session.sessionID) { meta in
                    meta.category = nil
                }
                self.metadata = RecordingMetadataManager.shared.getMetadata(for: self.session.sessionID)
                self.tableView.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: IndexPath(row: 1, section: Section.customization.rawValue))
        }
        
        present(alert, animated: true)
    }
    
    private func showTagEditor() {
        let vc = TagEditorViewController(session: session)
        vc.onUpdate = { [weak self] in
            self?.metadata = RecordingMetadataManager.shared.getMetadata(for: self?.session.sessionID ?? "")
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func toggleFavorite() {
        RecordingMetadataManager.shared.updateMetadata(for: session.sessionID) { meta in
            meta.isFavorite.toggle()
        }
        metadata = RecordingMetadataManager.shared.getMetadata(for: session.sessionID)
        tableView.reloadData()
    }
    
    // MARK: - Transcription Actions
    private func generateTranscription() {
        guard TranscriptionManager.shared.hasPermission() else {
            TranscriptionManager.shared.requestPermission { [weak self] granted in
                if granted {
                    self?.generateTranscription()
                } else {
                    self?.showTranscriptionPermissionAlert()
                }
            }
            return
        }
        
        let progressAlert = UIAlertController(title: "Transcribing", message: "Generating transcription...", preferredStyle: .alert)
        present(progressAlert, animated: true)
        
        TranscriptionManager.shared.transcribe(session: session, progress: { partial in
            progressAlert.message = "Processing..."
        }, completion: { [weak self] result in
            progressAlert.dismiss(animated: true) {
                guard let self = self else { return }
                
                switch result {
                case .success(let transcription):
                    RecordingMetadataManager.shared.updateMetadata(for: self.session.sessionID) { meta in
                        meta.transcription = transcription
                    }
                    self.metadata = RecordingMetadataManager.shared.getMetadata(for: self.session.sessionID)
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    self.showErrorAlert(error)
                }
            }
        })
    }
    
    private func showTranscription() {
        let vc = TranscriptionViewController(transcription: metadata.transcription ?? "")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func deleteTranscription() {
        let alert = UIAlertController(title: "Delete Transcription", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            RecordingMetadataManager.shared.updateMetadata(for: self.session.sessionID) { meta in
                meta.transcription = nil
            }
            self.metadata = RecordingMetadataManager.shared.getMetadata(for: self.session.sessionID)
            self.tableView.reloadData()
        })
        present(alert, animated: true)
    }
    
    private func showTranscriptionPermissionAlert() {
        let alert = UIAlertController(
            title: "Speech Recognition Required",
            message: "Enable speech recognition in Settings to transcribe recordings.",
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
    
    // MARK: - Action Methods
    private func playRecording() {
        let playbackVC = PlaybackViewController(session: session)
        navigationController?.pushViewController(playbackVC, animated: true)
    }
    
    private func exportRecording() {
        let alert = UIAlertController(title: "Export", message: "Choose format", preferredStyle: .actionSheet)
        
        for format in [SettingsManager.ExportFormat.m4a, .

@'
import UIKit

// MARK: - Recording Detail View Controller
class RecordingDetailViewController: UITableViewController {
    
    private let session: RecordingSession
    private var metadata: SessionMetadata
    
    private enum Section: Int, CaseIterable {
        case info
        case customization
        case transcription
        case actions
        
        var title: String? {
            switch self {
            case .info: return "Information"
            case .customization: return "Organize"
            case .transcription: return "Transcription"
            case .actions: return "Actions"
            }
        }
    }
    
    init(session: RecordingSession) {
        self.session = session
        self.metadata = RecordingMetadataManager.shared.getMetadata(for: session.sessionID)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recording Details"
        view.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(DetailCell.self, forCellReuseIdentifier: "DetailCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        switch sectionType {
        case .info: return 4
        case .customization: return 4
        case .transcription: return metadata.transcription == nil ? 1 : 2
        case .actions: return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch sectionType {
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            switch indexPath.row {
            case 0: cell.configure(title: "Date", value: dateFormatter.string(from: session.date))
            case 1: cell.configure(title: "Duration", value: formatDuration(session.totalDuration))
            case 2: cell.configure(title: "Segments", value: "\(session.segments.count)")
            case 3: cell.configure(title: "File Size", value: ByteCountFormatter.string(fromByteCount: session.totalSize, countStyle: .file))
            default: break
            }
            return cell
            
        case .customization:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "CustomCell")
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Custom Name"
                cell.detailTextLabel?.text = metadata.customName ?? "Not set"
            case 1:
                cell.textLabel?.text = "Category"
                cell.detailTextLabel?.text = metadata.category ?? "None"
            case 2:
                cell.textLabel?.text = "Tags"
                cell.detailTextLabel?.text = metadata.tags.isEmpty ? "None" : metadata.tags.joined(separator: ", ")
            case 3:
                cell.textLabel?.text = "Favorite"
                cell.accessoryType = metadata.isFavorite ? .checkmark : .none
            default: break
            }
            return cell
            
        case .transcription:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.textColor = .label
            if metadata.transcription == nil {
                cell.textLabel?.text = "Generate Transcription"
                cell.textLabel?.textColor = .systemBlue
                cell.accessoryType = .disclosureIndicator
            } else {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "View Transcription"
                    cell.accessoryType = .disclosureIndicator
                } else {
                    cell.textLabel?.text = "Delete Transcription"
                    cell.textLabel?.textColor = .systemRed
                    cell.accessoryType = .none
                }
            }
            return cell
            
        case .actions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.textColor = .label
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
            case 0: cell.textLabel?.text = "Play Recording"
            case 1: cell.textLabel?.text = "Export"
            case 2: cell.textLabel?.text = "Share"
            case 3:
                cell.textLabel?.text = "Delete"
                cell.textLabel?.textColor = .systemRed
                cell.accessoryType = .none
            default: break
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let sectionType = Section(rawValue: indexPath.section) else { return }
        
        switch sectionType {
        case .info: break
        case .customization:
            switch indexPath.row {
            case 0: showNameEditor()
            case 1: showCategoryPicker()
            case 2: showTagEditor()
            case 3: toggleFavorite()
            default: break
            }
        case .transcription:
            if metadata.transcription == nil {
                generateTranscription()
            } else {
                if indexPath.row == 0 { showTranscription() }
                else { deleteTranscription() }
            }
        case .actions:
            switch indexPath.row {
            case 0: playRecording()
            case 1: exportRecording()
            case 2: shareRecording()
            case 3: deleteRecording()
            default: break
            }
        }
    }
    
    private func showNameEditor() {
        let alert = UIAlertController(title: "Custom Name", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = self.metadata.customName }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let name = alert.textFields?.first?.text
            RecordingMetadataManager.shared.updateMetadata(for: self.session.sessionID) { $0.customName = name?.isEmpty == true ? nil : name }
            self.metadata = RecordingMetadataManager.shared.getMetadata(for: self.session.sessionID)
            self.tableView.reloadData()
        })
        present(alert, animated: true)
    }
    
    private func showCategoryPicker() {
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        for category in CategoryManager.shared.allCategories {
            alert.addAction(UIAlertAction(title: category, style: .default) { [weak self] _ in
                guard let self = self else { return }
                RecordingMetadataManager.shared.updateMetadata(for: self.session.sessionID) { $0.category = category }
                self.metadata = RecordingMetadataManager.shared.getMetadata(for: self.session.sessionID)
                self.tableView.reloadData()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        present(alert, animated: true)
    }
    
    private func showTagEditor() {
        let vc = TagEditorViewController(session: session)
        vc.onUpdate = { [weak self] in
            self?.metadata = RecordingMetadataManager.shared.getMetadata(for: self?.session.sessionID ?? "")
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func toggleFavorite() {
        RecordingMetadataManager.shared.updateMetadata(for: session.sessionID) { $0.isFavorite.toggle() }
        metadata = RecordingMetadataManager.shared.getMetadata(for: session.sessionID)
        tableView.reloadData()
    }
    
    private func generateTranscription() {
        guard TranscriptionManager.shared.hasPermission() else {
            TranscriptionManager.shared.requestPermission { [weak self] granted in
                if granted { self?.generateTranscription() }
            }
            return
        }
        let progressAlert = UIAlertController(title: "Transcribing", message: "Please wait...", preferredStyle: .alert)
        present(progressAlert, animated: true)
        TranscriptionManager.shared.transcribe(session: session, progress: { _ in }, completion: { [weak self] result in
            progressAlert.dismiss(animated: true) {
                guard let self = self else { return }
                if case .success(let text) = result {
                    RecordingMetadataManager.shared.updateMetadata(for: self.session.sessionID) { $0.transcription = text }
                    self.metadata = RecordingMetadataManager.shared.getMetadata(for: self.session.sessionID)
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    private func showTranscription() {
        let vc = TranscriptionViewController(transcription: metadata.transcription ?? "")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func deleteTranscription() {
        RecordingMetadataManager.shared.updateMetadata(for: session.sessionID) { $0.transcription = nil }
        metadata = RecordingMetadataManager.shared.getMetadata(for: session.sessionID)
        tableView.reloadData()
    }
    
    private func playRecording() {
        let vc = PlaybackViewController(session: session)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func exportRecording() {
        let alert = UIAlertController(title: "Export Format", message: nil, preferredStyle: .actionSheet)
        for format in [SettingsManager.ExportFormat.m4a, .mp3, .wav] {
            alert.addAction(UIAlertAction(title: format.rawValue, style: .default) { [weak self] _ in
                self?.doExport(format: format)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        present(alert, animated: true)
    }
    
    private func doExport(format: SettingsManager.ExportFormat) {
        let progress = UIAlertController(title: "Exporting...", message: nil, preferredStyle: .alert)
        present(progress, animated: true)
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            do {
                let url = try RecordingExporter().combineAndExport(session: self.session, format: format)
                DispatchQueue.main.async {
                    progress.dismiss(animated: true) { self.shareFile(url: url) }
                }
            } catch {
                DispatchQueue.main.async { progress.dismiss(animated: true) }
            }
        }
    }
    
    private func shareRecording() {
        doExport(format: .m4a)
    }
    
    private func shareFile(url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let popover = vc.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        present(vc, animated: true)
    }
    
    private func deleteRecording() {
        let alert = UIAlertController(title: "Delete Recording?", message: "This cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            for segment in self.session.segments {
                try? FileManager.default.removeItem(at: segment.url)
            }
            RecordingMetadataManager.shared.deleteMetadata(for: self.session.sessionID)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let h = Int(duration) / 3600
        let m = (Int(duration) % 3600) / 60
        let s = Int(duration) % 60
        return h > 0 ? String(format: "%dh %dm %ds", h, m, s) : String(format: "%dm %ds", m, s)
    }
}
