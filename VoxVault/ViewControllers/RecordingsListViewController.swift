import UIKit

// MARK: - Recordings List View Controller
class RecordingsListViewController: UITableViewController {
    
    private var allRecordings: [RecordingSession] = []
    private var filteredRecordings: [RecordingSession] = []
    private var isSearching = false
    private var currentFilter: FilterType = .all
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private enum FilterType: Equatable {
        case all
        case favorites
        case category(String)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recordings"
        view.backgroundColor = .systemBackground
        
        tableView.register(RecordingCell.self, forCellReuseIdentifier: "RecordingCell")
        
        setupNavigationBar()
        setupSearchController()
        loadRecordings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecordings()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Filter",
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search recordings, tags, transcriptions..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    @objc private func filterButtonTapped() {
        let alert = UIAlertController(title: "Filter Recordings", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "All Recordings", style: .default) { [weak self] _ in
            self?.applyFilter(.all)
        })
        
        alert.addAction(UIAlertAction(title: "Favorites Only", style: .default) { [weak self] _ in
            self?.applyFilter(.favorites)
        })
        
        let categories = CategoryManager.shared.allCategories
        if !categories.isEmpty {
            for category in categories {
                alert.addAction(UIAlertAction(title: "Category: \(category)", style: .default) { [weak self] _ in
                    self?.applyFilter(.category(category))
                })
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func applyFilter(_ filter: FilterType) {
        currentFilter = filter
        updateFilteredRecordings()
    }
    
    private func updateFilteredRecordings() {
        var recordings = allRecordings
        
        switch currentFilter {
        case .all:
            break
        case .favorites:
            recordings = RecordingMetadataManager.shared.getFavorites(from: recordings)
        case .category(let category):
            recordings = RecordingMetadataManager.shared.filterByCategory(category, in: recordings)
        }
        
        if isSearching, let searchText = searchController.searchBar.text, !searchText.isEmpty {
            recordings = RecordingMetadataManager.shared.searchRecordings(query: searchText, in: recordings)
        }
        
        filteredRecordings = recordings
        tableView.reloadData()
    }
    
    private var displayedRecordings: [RecordingSession] {
        return (isSearching || currentFilter != .all) ? filteredRecordings : allRecordings
    }
    
    // MARK: - Data Loading
    private func loadRecordings() {
        do {
            allRecordings = try RecordingFileManager.shared.fetchAllRecordings()
            updateFilteredRecordings()
            
            if allRecordings.isEmpty {
                showEmptyState()
            } else {
                tableView.backgroundView = nil
            }
        } catch {
            showErrorAlert(error)
        }
    }
    
    private func showEmptyState() {
        let label = UILabel()
        label.text = "No recordings yet\nStart recording to see your audio journals here"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        tableView.backgroundView = label
    }
    
    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedRecordings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath) as! RecordingCell
        let session = displayedRecordings[indexPath.row]
        let metadata = RecordingMetadataManager.shared.getMetadata(for: session.sessionID)
        cell.configure(with: session, metadata: metadata, dateFormatter: dateFormatter)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let session = displayedRecordings[indexPath.row]
        showRecordingDetail(for: session)
    }
    
    private func showRecordingDetail(for session: RecordingSession) {
        let detailVC = RecordingDetailViewController(session: session)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let session = displayedRecordings[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.showDeleteConfirmation(for: session, at: indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let exportAction = UIContextualAction(style: .normal, title: "Export") { [weak self] _, _, completion in
            self?.showExportOptions(for: session)
            completion(true)
        }
        exportAction.backgroundColor = .systemBlue
        exportAction.image = UIImage(systemName: "square.and.arrow.up")
        
        let metadata = RecordingMetadataManager.shared.getMetadata(for: session.sessionID)
        let favoriteAction = UIContextualAction(style: .normal, title: metadata.isFavorite ? "Unfavorite" : "Favorite") { [weak self] _, _, completion in
            self?.toggleFavorite(for: session)
            completion(true)
        }
        favoriteAction.backgroundColor = .systemYellow
        favoriteAction.image = UIImage(systemName: metadata.isFavorite ? "star.slash" : "star.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, exportAction, favoriteAction])
    }
    
    private func toggleFavorite(for session: RecordingSession) {
        RecordingMetadataManager.shared.updateMetadata(for: session.sessionID) { meta in
            meta.isFavorite.toggle()
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let session = displayedRecordings[indexPath.row]
            showDeleteConfirmation(for: session, at: indexPath)
        }
    }
    
    // MARK: - Delete Recording
    private func showDeleteConfirmation(for session: RecordingSession, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete Recording",
            message: "Are you sure you want to delete this recording? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteRecording(session, at: indexPath)
        })
        
        present(alert, animated: true)
    }
    
    private func deleteRecording(_ session: RecordingSession, at indexPath: IndexPath) {
        do {
            for segment in session.segments {
                try FileManager.default.removeItem(at: segment.url)
            }
            
            RecordingMetadataManager.shared.deleteMetadata(for: session.sessionID)
            
            if let allIndex = allRecordings.firstIndex(where: { $0.sessionID == session.sessionID }) {
                allRecordings.remove(at: allIndex)
            }
            if let filteredIndex = filteredRecordings.firstIndex(where: { $0.sessionID == session.sessionID }) {
                filteredRecordings.remove(at: filteredIndex)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if allRecordings.isEmpty {
                showEmptyState()
            }
        } catch {
            showErrorAlert(error)
        }
    }
    
    // MARK: - Export Recording
    private func showExportOptions(for session: RecordingSession) {
        let alert = UIAlertController(
            title: "Export Recording",
            message: "Choose export format",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        for format in [SettingsManager.ExportFormat.m4a, .mp3, .wav] {
            alert.addAction(UIAlertAction(title: format.rawValue, style: .default) { [weak self] _ in
                self?.exportRecording(session, format: format)
            })
        }
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    private func exportRecording(_ session: RecordingSession, format: SettingsManager.ExportFormat) {
        let progressAlert = UIAlertController(
            title: "Exporting",
            message: "Combining segments...",
            preferredStyle: .alert
        )
        present(progressAlert, animated: true)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let exporter = RecordingExporter()
                let exportedURL = try exporter.combineAndExport(session: session, format: format)
                
                DispatchQueue.main.async {
                    progressAlert.dismiss(animated: true) {
                        self?.shareExportedFile(url: exportedURL)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    progressAlert.dismiss(animated: true) {
                        self?.showErrorAlert(error)
                    }
                }
            }
        }
    }
    
    private func shareExportedFile(url: URL) {
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
    
    // MARK: - Alerts
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension RecordingsListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        isSearching = !searchText.isEmpty
        updateFilteredRecordings()
    }
}
