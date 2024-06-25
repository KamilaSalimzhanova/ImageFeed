import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    private let tokenKey = "OAuth2AccessToken"
    private let userDefaults = UserDefaults.standard
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let newValue else {
                assertionFailure("newValue of token is nil")
                return
            }
            KeychainWrapper.standard.set(newValue, forKey: tokenKey)
        }
    }
    func clear(){
        KeychainWrapper.standard.removeAllKeys()
    }
}
