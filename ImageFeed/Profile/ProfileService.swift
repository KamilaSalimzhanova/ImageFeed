import UIKit

final class ProfileService {
    
    private(set) var profile: Profile?
    private var lastToken: String?
    private var task: URLSessionTask?
    
    static let shared = ProfileService()
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void){
        assert(Thread.isMainThread)
        if lastToken == token { return }
        
        task?.cancel()
        lastToken = token
        
        guard let url = URL(string: Constants.profileURLString) else {
            print("[Fetch profile]: Error in URL request")
            completion(.failure(ProfileServiceError.invalidUrlRequest))
            return
         }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self, self.lastToken == token else {
                completion(.failure(ProfileServiceError.requestCancelled))
                return
            }
            switch result {
            case .success(let profileResponse):
                
                let profile = Profile(username: profileResponse.username, name: "\(profileResponse.firstName) \(profileResponse.lastName ?? "")", loginName: "@\(profileResponse.username)", bio: profileResponse.bio ?? "")
                
                self.profile = profile
                completion(.success(profile))
                self.task = nil
                
            case .failure(let error):
                print("[Fetch profile]: Error in url session data tasks - код ошибки \(error)")
                completion(.failure(error))
                self.lastToken = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func getProfile() -> Profile? {
         return self.profile
    }
}
