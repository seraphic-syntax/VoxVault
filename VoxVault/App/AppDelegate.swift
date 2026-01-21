import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        try? RecordingFileManager.shared.setup()
        AutoDeleteManager.shared.checkAndDeleteOldRecordings()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let recordingVC = RecordingViewController()
        let navigationController = UINavigationController(rootViewController: recordingVC)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name("AppDidBecomeActive"), object: nil)
    }
}
