import UIKit

enum AuthServiceError: Error {
    case invalidRequest
    case requestCancelled
    case jsonDecoder
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private var task: URLSessionTask?
    private var lastCode: String?
    let session = URLSession.shared
    
    private init() {}
    
    func fetchOAuthToken (_ code: String, completion: @escaping (Result<String, Error>) -> Void){
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                
                guard let self = self, self.lastCode == code else {
                    completion(.failure(AuthServiceError.requestCancelled))
                    return
                }
        
                switch result {
                case .success(let data):
                    completion(.success(data.accessToken))
                    self.task = nil
                case .failure(let error):
                    print("Network error in OAuth2Service \(error)")
                    completion(.failure(error))
                    self.lastCode = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard
            let baseURL = URL(string: "https://unsplash.com")
        else {
             print("BaseUrl cannot be constructed")
             return nil
         }
        
         guard
            let url = URL(
             string: "/oauth/token"
             + "?client_id=\(Constants.accessKey)"
             + "&&client_secret=\(Constants.secretKey)"
             + "&&redirect_uri=\(Constants.redirectURI)"
             + "&&code=\(code)"
             + "&&grant_type=authorization_code",
             relativeTo: baseURL
         ) else {
             print("Unable to construct makeOAuthTokenRequestUrl")
             return nil
         }
        
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         return request
     }
}
