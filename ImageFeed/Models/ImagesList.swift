import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: URL?
    let largeImageURL: URL?
    let isLiked: Bool
    
    static func mapPhotoResultToPhoto(_ photoResult: PhotoResult, date: ISO8601DateFormatter) -> Photo {
        let createdAt = date.date(from: photoResult.createdAt ?? "")
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
