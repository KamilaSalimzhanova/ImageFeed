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
                print("[fetchOAuthToken]: Error in lastCode is same as code")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                print("[fetchOAuthToken]: Error in lastCode is same as code")
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
                    print("[OAuth2Service fetch oauth token]: request cancelled")
                    completion(.failure(AuthServiceError.requestCancelled))
                    return
                }
        
                switch result {
                case .success(let data):
                    completion(.success(data.accessToken))
                case .failure(let error):
                    print("[OAuth2Service fetch oauth token]: Error in object task - код ошибки \(error)")
                    completion(.failure(error))
                    self.lastCode = nil
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard
            let baseURL = URL(string: "https://unsplash.com")
        else {
            print("[makeOAuthTokenRequest]: url cannot be constructed")
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
             print("[makeOAuthTokenRequest]: urlRequest for token cannot be constructed")
             return nil
         }
        
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         return request
     }
}
