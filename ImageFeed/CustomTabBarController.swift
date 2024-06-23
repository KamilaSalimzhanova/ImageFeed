import UIKit

class CustomTabBarController: UITabBarController {
    let showProfileSegueIdentifier = "ShowProfileView"
    var profileService = ProfileService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showProfileSegueIdentifier {
            guard
                let profileViewController = segue.destination as? ProfileViewController
            else {
                fatalError("Failed to prepare for \(showProfileSegueIdentifier)")
            }
            profileViewController.viewDidLoad()
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
