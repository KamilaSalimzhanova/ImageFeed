import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    var profileService = ProfileService.shared
    var profileClearService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var gradientLayer: CAGradientLayer?
    private var gradientChangeAnimation: CABasicAnimation?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfilePhoto")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        return label
    }()
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "BackButton")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "YP Black") 
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                gradientLayer?.removeFromSuperlayer()
                self.updateAvatar()
            }
        updateAvatar()
        addSubviews()
        updateProfileDetails()
        makeConstraints()
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
                let imageUrl = URL(string: profileImageURL)
        else {
            return
            
        }
        let cache = ImageCache.default
        cache.clearDiskCache()
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageUrl,
          placeholder: UIImage(named: "placeholder"),
          options: [
            .processor(processor),
            .transition(.fade(1))
          ]) { result in
              switch result {
              case .success(let value):
                  print(value.image)
                  print(value.cacheType)
                  print(value.source)
              case .failure(let error):
                  print(error)
              }
          }
    }
    
    private func updateProfileDetails() {
        if let profile = profileService.getProfile() {
            nameLabel.text = profile.name
            loginLabel.text = profile.loginName
            descriptionLabel.text = profile.bio
        } else {
            return
        }
    }
    
    private func addSubviews() {
        [
            imageView,
            nameLabel,
            loginLabel,
            descriptionLabel,
            logoutButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            
            loginLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: loginLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    private func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = imageView.bounds
        gradientLayer?.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 0.6).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 0.6).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 0.6).cgColor
        ]
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer?.cornerRadius = imageView.bounds.width / 2
        gradientLayer?.masksToBounds = true
        imageView.layer.addSublayer(gradientLayer!)
        
       gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
       gradientChangeAnimation?.duration = 3.0
       gradientChangeAnimation?.repeatCount = .infinity
       gradientChangeAnimation?.fromValue = [0, 0.1, 0.3]
       gradientChangeAnimation?.toValue = [0, 0.8, 1]
       gradientLayer?.add(gradientChangeAnimation!, forKey: "locationsChange")
    }
    
    @objc
    private func didTapBackButton() {
        let alert = UIAlertController(title: "Пока!", message: "Вы хотите выйти?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Да!", style: .default) { [weak self] _ in
            guard let self else {return}
            self.profileClearService.logout()
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            window.rootViewController = SplashViewController()
            window.makeKeyAndVisible()
        }
       
        let noAction = UIAlertAction(title: "Нет", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
    @objc private func profileUpdated() {
        updateProfileDetails()
    }
}
