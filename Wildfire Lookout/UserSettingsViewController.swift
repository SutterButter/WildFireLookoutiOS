//
//  UserSettingsViewController.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 2/25/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserSettingsViewController: UIViewController {

    @IBAction func logOutPressed(_ sender: Any) {
        do {
            // First get rid of cached data
            var mapsTab = self.tabBarController?.viewControllers?[0] as! MapsViewController
            mapsTab.detatchListeners()
            
            
            try Auth.auth().signOut()
            self.navigationController?.popViewController(animated: false)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // vc is the Storyboard ID that you added
            // as! ... Add your ViewController class name that you want to navigate to
            let controller = storyboard.instantiateViewController(withIdentifier: "signIn") as! LogInViewController
            self.present(controller, animated: true, completion: { () -> Void in })
        } catch let error {
            print("Error signing out the user.")
            print(error)
            let alert = UIAlertController(title: "Error Signing Out", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
