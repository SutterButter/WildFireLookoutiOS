//
//  SetAlertSettingsViewController.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 3/13/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseFirestore
//import GooglePlacePicker

class SetAlertSettingsViewController: UIViewController, LocationSelectedDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var textNotificationsSwitch: UISwitch!
    @IBOutlet weak var callNotificationsSwitch: UISwitch!
    @IBOutlet weak var emailNotificationsSwitch: UISwitch!
    
    @IBOutlet weak var textNumber: UITextField!
    @IBOutlet weak var callNumber: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var selectLocationButton: UIButton!
    
    var selectedLocation: CLLocationCoordinate2D? = nil
    var alertSetting: AlertSettings? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide keyboards when clicking off the keyboard
        self.hideKeyboard()
        
        // Hide the map view until a location is set
        mapView.isHidden = true
        
        if (alertSetting != nil) {
            // Set all the fields according to the AlertSetting passed in
            name.text = alertSetting!.name
            
            pushNotificationsSwitch.isOn = alertSetting!.pushNotificationsEnabled
            textNotificationsSwitch.isOn = alertSetting!.textsEnabled
            callNotificationsSwitch.isOn = alertSetting!.callsEnabled
            emailNotificationsSwitch.isOn = alertSetting!.emailsEnabled
            
            if (alertSetting!.textNumbers.count > 0) {
                textNumber.text = alertSetting?.textNumbers[0]
            }
            if (alertSetting!.callNumbers.count > 0) {
                callNumber.text = alertSetting?.callNumbers[0]
            }
            if (alertSetting!.emails.count > 0) {
                emailAddress.text = alertSetting?.emails[0]
            }
            
            if (!(alertSetting!.coordinates.latitude == 0.0 && alertSetting?.coordinates.longitude == 0.0)) {
                selectedLocation = alertSetting!.coordinates.locationValue().coordinate
                selectLocationButton.setTitle("Select New Location", for: .normal)
                
                // Show the map view and recenter over the selected position
                mapView.isHidden = false
                let camera = GMSCameraPosition.camera(withLatitude: selectedLocation!.latitude, longitude: selectedLocation!.longitude, zoom: 12.0)
                mapView.camera = camera
                
                // Display a marker at the selected location
                mapView.clear()
                let marker = GMSMarker(position: selectedLocation!)
                marker.title = "Selected Location"
                marker.map = mapView
            }
            
            let button = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonTapped))
            self.navigationItem.rightBarButtonItem = button
            
        }
    }
    
    // This function goes over the alertSettings and if they are different push to database
    @objc func saveButtonTapped() {
        let newAlertSetting = AlertSettings(db: alertSetting!.db)
        newAlertSetting.userId = alertSetting!.userId
        newAlertSetting.id = alertSetting!.id
        
        // Name Setting
        print("Name Settings")
        if name.text != nil && name.text != "" {
            newAlertSetting.name = name.text!
        } else {
            let alert = UIAlertController(title: "Name Empty", message: "Name must not be empty.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if (!pushNotificationsSwitch.isOn && !textNotificationsSwitch.isOn && !callNotificationsSwitch.isOn && !emailNotificationsSwitch.isOn) {
            let alert = UIAlertController(title: "No Notifications", message: "At least one form of notifications must be turned on.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Push Notification Settings
        print("Push Settings")
        newAlertSetting.pushNotificationsEnabled = pushNotificationsSwitch.isOn
        
        // Texts Settings
        print("Text Settings")
        newAlertSetting.textsEnabled = textNotificationsSwitch.isOn
        if textNumber.text != nil && textNumber.text != "" {
            newAlertSetting.textNumbers = [textNumber.text!]
        }
        if newAlertSetting.textsEnabled && newAlertSetting.textNumbers.count <= 0 {
            let alert = UIAlertController(title: "Text Error", message: "If texts are turned on, you must enter a phone number.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Calls Settings
        print("Call Settings")
        newAlertSetting.callsEnabled = callNotificationsSwitch.isOn
        if callNumber.text != nil && callNumber.text != "" {
            newAlertSetting.callNumbers = [callNumber.text!]
        }
        if newAlertSetting.callsEnabled && newAlertSetting.callNumbers.count <= 0 {
            let alert = UIAlertController(title: "Call Error", message: "If calls are turned on, you must enter a phone number.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Emails Settings
        print("Email Settings")
        newAlertSetting.emailsEnabled = emailNotificationsSwitch.isOn
        if emailAddress.text != nil && emailAddress.text != "" {
            newAlertSetting.emails = [emailAddress.text!]
        }
        if newAlertSetting.emailsEnabled && newAlertSetting.emails.count <= 0 {
            let alert = UIAlertController(title: "Email Error", message: "If emails are turned on, you must enter an email.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Location Setting
        print("Location Settings")
        if (selectedLocation != nil) {
            newAlertSetting.coordinates = GeoPoint(latitude: selectedLocation!.latitude, longitude: selectedLocation!.longitude)
        } else {
            let alert = UIAlertController(title: "No Location", message: "Location must be set.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if (newAlertSetting.isEqual(alertSetting!)) {
            print("Alert Settings are the same")
            self.navigationController?.popViewController(animated: true)
            return
        } else {
            alertSetting! = newAlertSetting
        }
        
        let watchLocation = alertSetting!.getFirebaseObject()
        
        // If the document already exists overwrite it, otherwise create a new one
        if (alertSetting!.id != "") {
            print("old")
            alertSetting!.db.collection("watchLocations").document(alertSetting!.id).setData(watchLocation) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    let alert = UIAlertController(title: "Error Saving Alert", message: err.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    print("Document successfully written!")
                    // Go to the previous thing and reload data
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            print("new")
            alertSetting!.db.collection("watchLocations").addDocument(data: watchLocation) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    let alert = UIAlertController(title: "Error Saving Alert", message: err.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    print("Document successfully written!")
                    // Go to the previous thing and reload data
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
    // This function is called from SelectPlaceViewController when the selected location is returned
    func locationSelected(location: CLLocationCoordinate2D, zoom: Float) {
        print("Called")
        selectedLocation = location
        selectLocationButton.setTitle("Select New Location", for: .normal)
        
        // Show the map view and recenter over the selected position
        mapView.isHidden = false
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: zoom)
        mapView.camera = camera
        
        // Display a marker at the selected location
        mapView.clear()
        let marker = GMSMarker(position: location)
        marker.title = "Selected Location"
        marker.map = mapView
        
    }
    
    @IBAction func selectLocationClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "selectLocationSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectLocationSegue" {
            let selectPlaceViewController = segue.destination as! SelectPlaceViewController
            selectPlaceViewController.delegate = self
        }
    }

}
