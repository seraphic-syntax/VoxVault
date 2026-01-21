import UIKit

// MARK: - Settings View Controller
class SettingsViewController: UITableViewController {
    
    private enum Section: Int, CaseIterable {
        case segmentDuration, audioQuality, exportFormat, autoDelete
        
        var title: String {
            switch self {
            case .segmentDuration: return "Segment Duration"
            case .audioQuality: return "Audio Quality"
            case .exportFormat: return "Export Format"
            case .autoDelete: return "Auto-Delete"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .segmentDuration: return SettingsManager.presetDurations.count
        case .audioQuality: return 3
        case .exportFormat: return 3
        case .autoDelete: return SettingsManager.autoDeleteOptions.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
        case .segmentDuration:
            let preset = SettingsManager.presetDurations[indexPath.row]
            cell.textLabel?.text = preset.title
            cell.accessoryType = SettingsManager.shared.segmentDuration == preset.duration ? .checkmark : .none
            
        case .audioQuality:
            let qualities: [SettingsManager.AudioQuality] = [.low, .medium, .high]
            let quality = qualities[indexPath.row]
            cell.textLabel?.text = quality.rawValue
            cell.accessoryType = SettingsManager.shared.audioQuality == quality ? .checkmark : .none
            
        case .exportFormat:
            let formats: [SettingsManager.ExportFormat] = [.m4a, .mp3, .wav]
            let format = formats[indexPath.row]
            cell.textLabel?.text = format.rawValue
            cell.accessoryType = SettingsManager.shared.exportFormat == format ? .checkmark : .none
            
        case .autoDelete:
            let option = SettingsManager.autoDeleteOptions[indexPath.row]
            cell.textLabel?.text = option.title
            cell.accessoryType = SettingsManager.shared.autoDeleteDays == option.days ? .checkmark : .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
        case .segmentDuration:
            SettingsManager.shared.segmentDuration = SettingsManager.presetDurations[indexPath.row].duration
        case .audioQuality:
            let qualities: [SettingsManager.AudioQuality] = [.low, .medium, .high]
            SettingsManager.shared.audioQuality = qualities[indexPath.row]
        case .exportFormat:
            let formats: [SettingsManager.ExportFormat] = [.m4a, .mp3, .wav]
            SettingsManager.shared.exportFormat = formats[indexPath.row]
        case .autoDelete:
            SettingsManager.shared.autoDeleteDays = SettingsManager.autoDeleteOptions[indexPath.row].days
        }
        
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }
}
