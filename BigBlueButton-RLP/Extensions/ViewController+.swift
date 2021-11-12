import UIKit

extension UIViewController {
    
    
    /// Presents a simple AlertController.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message of the alert.
    func presentSimpleAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertVC, animated: true)
    }
}
