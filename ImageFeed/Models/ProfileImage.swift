import Foundation

struct UserResult: Codable {
    let profileImage: ImageSize
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
struct ImageSize: Codable {
    let small: String
}
