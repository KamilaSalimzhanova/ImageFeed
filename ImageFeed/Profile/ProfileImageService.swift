import UIKit

struct UserResult: Codable {
    let profileImage: ImageSize
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
struct ImageSize: Codable {
    let small: String
}

final class ProfileImageService {
    
    private var task: URLSessionTask?
    private var lastUserName: String?
    private var oAuth2TokenStorage = OAuth2TokenStorage.shared
    private (set) var avatarURL: String?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeRequest(username) else {
            assertionFailure("Image service url request is not built ")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else {return}
            switch result {
            case .success(let profileImageUrl):
                completion(.success(profileImageUrl.profileImage.small))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageUrl.profileImage.small])
                self.avatarURL = profileImageUrl.profileImage.small
            case .failure(let error):
                print("Network error in profile image service \(error)")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}

extension ProfileImageService {
    private func makeRequest(_ username: String) -> URLRequest? {
        var urlComponents = URLComponents()
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            assertionFailure("BaseUrl cannot be constructed")
            return nil
        }
        urlComponents.path = "/users/\(username)"
        guard let url = urlComponents.url(relativeTo: baseURL) else {
            assertionFailure("Url is not constructed")
            return nil
        }
        guard let token = oAuth2TokenStorage.token else {
            assertionFailure("token is nil in image service of the profile")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
