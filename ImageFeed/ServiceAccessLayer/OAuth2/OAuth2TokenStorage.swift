import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    private let tokenKey = "OAuth2AccessToken"
    private let userDefaults = UserDefaults.standard
    var token: String? {
        get {
            return userDefaults.string(forKey: tokenKey)
        }
        set {
            userDefaults.set(newValue, forKey: tokenKey)
        }
    }
}
