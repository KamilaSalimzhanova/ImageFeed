import Foundation

private let dateTimeDefaultFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
    return dateFormatter
}()

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(_ photoResult: PhotoResult){
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        let dateFormatter = ISO8601DateFormatter()
        if let createdAtString = photoResult.createdAt,
            let date = dateFormatter.date(from: createdAtString) {
            self.createdAt = date
        } else {
            self.createdAt = nil
            print("Failed to parse createdAt date for photo with id: \(photoResult.id)")
        }
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser
    }
}
struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}
struct UrlsResult: Decodable {
    let full: String
    let thumb: String
}
