import UIKit

// MARK: - Recording Cell
class RecordingCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let favoriteIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .systemYellow
        iv.isHidden = true
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(favoriteIcon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            favoriteIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            favoriteIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteIcon.widthAnchor.constraint(equalToConstant: 16),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: favoriteIcon.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            durationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            durationLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 4),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        accessoryType = .disclosureIndicator
    }
    
    func configure(with session: RecordingSession, metadata: SessionMetadata, dateFormatter: DateFormatter) {
        titleLabel.text = metadata.customName ?? dateFormatter.string(from: session.date)
        
        var detail = "\(session.segments.count) segment(s)"
        if let cat = metadata.category { detail += " • \(cat)" }
        detailLabel.text = detail
        
        let h = Int(session.totalDuration) / 3600
        let m = (Int(session.totalDuration) % 3600) / 60
        let s = Int(session.totalDuration) % 60
        durationLabel.text = h > 0 ? String(format: "%dh %dm %ds", h, m, s) : String(format: "%dm %ds", m, s)
        
        favoriteIcon.isHidden = !metadata.isFavorite
    }
}
