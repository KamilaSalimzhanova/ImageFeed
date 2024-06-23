import Foundation

final class ImagesListService {
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    let session = URLSession.shared
    
    static let shared = ImagesListService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {}
    
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        currentTask?.cancel()
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let urlRequest = makePhotosRequest(page: nextPage) else {
            print("[fetchPhotosNextPage]: Could not fetch url request for photos next page")
            return
        }
        
        let task = session.objectTask(for: urlRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResult):
                    if self.lastLoadedPage == nil {
                        self.lastLoadedPage = 1
                    } else {
                        self.lastLoadedPage! += 1
                    }
                    self.photos.append(contentsOf: photoResult.map {Photo($0)})
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                case .failure(let error):
                    print("[fetchPhotosNextPage]: Error fetching photos - \(error)")
                }
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
    
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
        return request
    }
}
