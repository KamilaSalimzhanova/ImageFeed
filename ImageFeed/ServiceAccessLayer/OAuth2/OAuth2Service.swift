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
    
    private init() {}
    
    func fetchOAuthToken (_ code: String, completion: @escaping (Result<String, Error>) -> Void){
        assert(Thread.isMainThread)
        
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request){[weak self] result in
            DispatchQueue.main.async {
                
                guard let self = self, self.lastCode == code else {
                    completion(.failure(AuthServiceError.requestCancelled))
                    return
                }
                
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        completion(.success(tokenResponse.accessToken))
                    } catch {
                        completion(.failure(AuthServiceError.jsonDecoder))
                        self.lastCode = nil
                    }
                case .failure(let error):
                    print("Произошла сетевая ошибка: \(error)")
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
