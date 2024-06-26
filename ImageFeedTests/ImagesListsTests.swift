@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase{
    func testImagesListLoad() {
        //given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.loadImages()
        
        //then
        XCTAssertTrue(presenter.loadImageCalled)
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var loadImageCalled: Bool = false
    var view: ImagesListViewControllerProtocol?

    func loadImages(){
        loadImageCalled = true
    }
    
    func tapLike(id: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void){}
}
