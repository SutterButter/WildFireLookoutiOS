//
//  LogInViewController.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 2/24/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBAction func loginPressed(_ sender: Any) {
        // check email and password not empty
        if let email = self.emailField.text, email != "", let password = self.passwordField.text, password != "" {
            // Start loading the user
            loadingIndicator.startAnimating()
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                // Done loading user
                self.loadingIndicator.stopAnimating()
                
                // If error show error
                if let error = error {
                    let alert = UIAlertController(title: "Problems Logging In", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // Go to landing screen
                    self.performSegue(withIdentifier: "signInToLandingSegue", sender: self)
                }
            }
        } else { // if email or password is emtpy display message
            let alert = UIAlertController(title: "Email/Password Empty", message: "email/password can't be empty", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
// Extension will close the keyboard when clicking outside of the 
extension UIViewController {
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
