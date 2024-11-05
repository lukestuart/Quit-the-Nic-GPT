import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Initialize window with navigation controller and root view controller
        let quitNicotineVC = QuitNicotineViewController()
        let navigationController = UINavigationController(rootViewController: quitNicotineVC)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()

        // Load saved data into appState
        if let savedUsage = UserDefaults.standard.value(forKey: "dailyUsage") as? Int {
            quitNicotineVC.appState.dailyUsage = savedUsage
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Optional: Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Optional: Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Optional: Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Optional: Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save dailyUsage when the app enters the background
        if let quitNicotineVC = (window?.rootViewController as? UINavigationController)?.viewControllers.first as? QuitNicotineViewController {
            UserDefaults.standard.set(quitNicotineVC.appState.dailyUsage, forKey: "dailyUsage")
        }
    }
}
