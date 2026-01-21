import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        try? RecordingFileManager.shared.setup()
        AutoDeleteManager.shared.checkAndDeleteOldRecordings()
        
        window = UIWindow(windowScene: windowScene)
        
        let recordingVC = RecordingViewController()
        let navigationController = UINavigationController(rootViewController: recordingVC)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(name: NSNotification.Name("AppDidBecomeActive"), object: nil)
    }
}
