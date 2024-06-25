import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    weak var delegate: ImagesListCellDelegate?
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    func configCellImage(for photo: Photo){
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        guard let thumbImageURL = photo.thumbImageURL else {
            print("thumb image url is empty")
            return
        }
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: thumbImageURL, placeholder: UIImage(named: "imageListPlaceholder")) { result in
              switch result {
              case .success(let image):
                  self.cellImage.contentMode = .scaleAspectFill
                  self.cellImage.image = image.image
              case .failure(let error):
                  print(error)
                  self.cellImage.image = UIImage(named: "imageListPlaceholder")
              }
          }
        dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        setLiked(isLiked: photo.isLiked)
    }
    func setLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_on") : UIImage(named: "like_off")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    static func clear(){
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache ()
        cache.cleanExpiredMemoryCache()
        cache.backgroundCleanExpiredDiskCache()
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
