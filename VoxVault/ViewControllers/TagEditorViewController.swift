import UIKit

// MARK: - Tag Editor View Controller
class TagEditorViewController: UITableViewController {
    
    private let session: RecordingSession
    private var tags: [String] = []
    var onUpdate: (() -> Void)?
    
    init(session: RecordingSession) {
        self.session = session
        super.init(style: .insetGrouped)
        self.tags = RecordingMetadataManager.shared.getMetadata(for: session.sessionID).tags
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Tags"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTag))
    }
    
    @objc private func addTag() {
        let alert = UIAlertController(title: "Add Tag", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Tag name" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let tag = alert.textFields?.first?.text, !tag.isEmpty else { return }
            self?.tags.append(tag)
            self?.saveAndReload()
        })
        present(alert, animated: true)
    }
    
    private func saveAndReload() {
        RecordingMetadataManager.shared.updateMetadata(for: session.sessionID) { $0.tags = self.tags }
        tableView.reloadData()
        onUpdate?()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tags[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tags.remove(at: indexPath.row)
            saveAndReload()
        }
    }
}
