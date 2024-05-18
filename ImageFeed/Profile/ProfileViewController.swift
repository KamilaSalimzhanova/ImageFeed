import UIKit

final class ProfileViewController: UIViewController {
    
    private var imageView: UIImageView?
    private var nameLabel: UILabel?
    private var loginLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var logoutButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profleImageSetUp()
        nameLabelSetUp()
        loginLabelSetUp()
        descriptionLabelSetUp()
        logoutButtonSetUp()
    }
    private func profleImageSetUp() {
        let profileImage = UIImage(named: "ProfilePhoto")
        let imageView = UIImageView(image: profileImage)
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 31).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        
        self.imageView = imageView
    }
    private func nameLabelSetUp() {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        view.addSubview(label)
        
        guard let imageView = self.imageView else {return}
        
        label.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        self.nameLabel = label
    }
    private func loginLabelSetUp() {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        view.addSubview(label)
        
        guard let nameLabel = self.nameLabel else {return}
        
        label.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        self.loginLabel = label
    }
    private func descriptionLabelSetUp() {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        view.addSubview(label)
        
        guard let loginLabel = self.loginLabel else {return}
        
        label.leadingAnchor.constraint(equalTo: loginLabel.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8).isActive = true
        
        self.descriptionLabel = label
    }
    private func logoutButtonSetUp() {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "BackButton")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        guard let imageView = self.imageView else { return }
        
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.logoutButton = button
    }
    @objc
       private func didTapButton() {
       }
}
