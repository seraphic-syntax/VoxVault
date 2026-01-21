import UIKit

// MARK: - Transcription View Controller
class TranscriptionViewController: UIViewController {
    
    private let transcription: String
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = .systemFont(ofSize: 16)
        tv.isEditable = false
        return tv
    }()
    
    init(transcription: String) {
        self.transcription = transcription
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transcription"
        view.backgroundColor = .systemBackground
        
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        textView.text = transcription
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }
    
    @objc private func share() {
        let vc = UIActivityViewController(activityItems: [transcription], applicationActivities: nil)
        if let popover = vc.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(vc, animated: true)
    }
}
