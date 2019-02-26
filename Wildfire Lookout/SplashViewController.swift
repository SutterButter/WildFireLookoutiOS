//
//  SplashViewController.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 2/24/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation

class SplashViewController: UIViewController {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        enableLocationServices()
        
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil) { // a user is signed in, skip to main page
                print("USER SIGNED IN")
                sleep(1)
                self.performSegue(withIdentifier: "splashToLandingSegue", sender: self)
            } else { // no user signed in, do nothing
                print("NO USER SIGNED IN")
                sleep(1)
                self.performSegue(withIdentifier: "splashToSignInSegue", sender: self)
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    func enableLocationServices() {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            //disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            //enableMyWhenInUseFeatures()
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            //enableMyAlwaysFeatures()
            break
        }
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
