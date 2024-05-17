import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private var AvatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }    
    @IBAction func didTapLogoutButton() {
    }
}
