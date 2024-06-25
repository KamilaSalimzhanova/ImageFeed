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
    let thumbImageURL: URL?
    let largeImageURL: URL?
    let isLiked: Bool
    
    static func mapPhotoResultToPhoto(_ photoResult: PhotoResult) -> Photo {
        let dateFormatter = ISO8601DateFormatter()
        let createdAt: Date?
        if let createdAtString = photoResult.createdAt,
           let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = nil
            print("Failed to parse createdAt date for photo with id: \(photoResult.id)")
        }
        
        let thumbImageURL = URL(string: photoResult.urls.thumb)
        let largeImageURL = URL(string: photoResult.urls.full)
        
        return Photo(
            id: photoResult.id,
            size: CGSize(width: photoResult.width, height: photoResult.height),
            createdAt: createdAt,
            welcomeDescription: photoResult.description,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            isLiked: photoResult.likedByUser
        )
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
