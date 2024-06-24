import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    private let placeholderImageView = UIImageView(image: UIImage(named: "single_image_placeholder"))
    var image: URL?
    var uiImage: UIImage?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        addBackground()
        showFullImage(url: self.image)
        imageView.contentMode = .scaleAspectFit
    }
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton() {
        guard let uiImage else {return}
        let share = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    private func addBackground(){
        placeholderImageView.contentMode = .center
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderImageView)
        placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func showFullImage(url: URL?) {
        guard let url else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                placeholderImageView.removeFromSuperview()
                self.uiImage = imageResult.image
                self.imageView.image = imageResult.image
                self.imageView.frame = CGRect(origin: .zero, size: imageResult.image.size)
                self.scrollView.contentSize = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure(let error):
                print("[showFullImage] \(error.localizedDescription)")
                self.showError(url: url)
            }
        }
    }
    private func showError(url: URL) {
        let alert = UIAlertController(title: "Что-то пошло не так.", message: "Попробовать ещё раз?", preferredStyle: .alert)
        let repeats = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self else { return }
            self.showFullImage(url: url)
        }
        let cancel = UIAlertAction(title: "Не надо", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(cancel)
        alert.addAction(repeats)
        present(alert, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
}
