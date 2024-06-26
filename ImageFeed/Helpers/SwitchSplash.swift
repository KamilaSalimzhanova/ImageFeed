import UIKit

final class SwitchSplash {
    static let shared = SwitchSplash()
    private init() {}
    
    func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
            
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}
