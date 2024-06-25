import Foundation

final class ImagesListService {
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private let dateFormatter = ISO8601DateFormatter()
    let session = URLSession.shared
    
    static let shared = ImagesListService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {}
    
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let urlRequest = makePhotosRequest(page: nextPage) else {
            print("[fetchPhotosNextPage]: Could not fetch url request for photos next page")
            return
        }
        
        let task = session.objectTask(for: urlRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photoResult):
                if let currentPage = self.lastLoadedPage {
                    self.lastLoadedPage = currentPage + 1
                } else {
                    self.lastLoadedPage = 1
                }
                self.photos.append(contentsOf: photoResult.map {Photo.mapPhotoResultToPhoto($0, date: self.dateFormatter)})
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
            case .failure(let error):
                print("[fetchPhotosNextPage]: Error fetching photos - \(error)")
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        if currentTask != nil {
            currentTask?.cancel()
        }
        
        guard let urlRequest = changeLikeRequest(photoId: photoId, isLiked: isLike) else {
            print("[changeLike]: Could not fetch url request for changing like")
            return
        }
        
        let task = session.objectTask(for: urlRequest) {[weak self] (result: Result<PhotoLike, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photo):
                guard let index = self.photos.firstIndex(where: {$0.id == photo.photo.id}) else {
                    print("liked photo id is not found in the current list")
                    return
                }
                let photo = self.photos[index]
                let newPhotoResult = PhotoResult(
                    id: photo.id,
                    createdAt: photo.createdAt?.description,
                    width: Int(photo.size.width),
                    height: Int(photo.size.height),
                    likedByUser: !photo.isLiked,
                    description: photo.welcomeDescription,
                    urls: UrlsResult(full: photo.largeImageURL?.absoluteString ?? "", thumb: photo.thumbImageURL?.absoluteString ?? ""))
                let newPhoto = Photo.mapPhotoResultToPhoto(newPhotoResult, date: self.dateFormatter)
                self.photos[index] = newPhoto
                completion(.success(()))
            case .failure(let error):
                print("[session object task in images list service] \(error)")
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
}

extension ImagesListService {
    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(url: Constants.defaultBaseURL.appendingPathComponent("/photos"), resolvingAgainstBaseURL: false) else {
            print("[makePhotosRequesnt]: Could not make URL request from \(Constants.defaultBaseURL.appendingPathComponent("/photos"))")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else {
            print("[makePhotosRequesnt]: Could not retrieve url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = OAuth2TokenStorage.shared.token else {
            print("bearer token does not exist")
            return nil
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func changeLikeRequest(photoId: String, isLiked: Bool) -> URLRequest? {
        let path = "/photos/\(photoId)/like"
        
        guard let urlComponents = URLComponents(url: Constants.defaultBaseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            print("[changeLikeRequest]: Could not make URL request from \(Constants.defaultBaseURL.appendingPathComponent(path))")
            return nil
        }
        
        guard let url = urlComponents.url else {
            print("[changeLikeRequest]: Could not retrieve URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLiked ? "POST" : "DELETE"
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Bearer token does not exist")
            return nil
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
