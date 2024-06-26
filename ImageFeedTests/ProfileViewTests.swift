@testable import ImageFeed
import XCTest
import SwiftKeychainWrapper

final class ProfileViewTests: XCTestCase{
    func testProfileViewControllerUpdateAvatar() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.profileObserver()
        
        //then
        XCTAssertTrue(viewController.updateAvatarCalled)
    }
    
    func testControllerAskAvatarURLfromPresenter() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.updateAvatar()
        
        //then
        XCTAssertTrue(presenter.getAvaterUrlCalled)
    }
    
    func testProfileLogout() {
        //given
        let viewController = ProfileViewPresenter()
        let authToken = KeychainWrapper.standard.string(forKey: "authToken")
        
        //when
        viewController.logoutProfile()
        
        //then
        XCTAssertEqual(authToken, nil)
    }
}


final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var getAvaterUrlCalled: Bool = false
    var view: ImageFeed.ProfileViewControllerProtocol?
    
    func getAvatarURL() -> URL? {
        getAvaterUrlCalled = true
        return nil
    }
    func profileObserver() {}
    func logoutProfile() {}
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateAvatarCalled: Bool = false
    var presenter: ImageFeed.ProfilePresenterProtocol?
    
    var loadRequestCalled: Bool = false

    func updateAvatar() {
        updateAvatarCalled = true
    }
}
