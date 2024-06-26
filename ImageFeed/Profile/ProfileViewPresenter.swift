import UIKit

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func profileObserver()
    func logoutProfile()
    func getAvatarURL() -> URL?

}

final class ProfileViewPresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var profileClearService = ProfileLogoutService.shared
    private var profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let switchSplash = SwitchSplash.shared
    
    func profileObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                view?.updateAvatar()
            }
        view?.updateAvatar()
    }
    
    func getAvatarURL() -> URL? {
        let imageUrl = profileImageService.avatarURL ?? ""
        return URL(string: imageUrl)
    }
    
    func logoutProfile() {
        self.profileClearService.logout()
        switchSplash.switchToSplashScreen()
    }
}
