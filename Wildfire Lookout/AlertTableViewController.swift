//
//  AlertTableViewController.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 3/9/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase

// The firestore database
var db:Firestore? = nil


class AlertTableViewController: UITableViewController, AlertCellDelegate {
    
    var alertSettings = [AlertSettings]()
    var savedAlertSettings = [AlertSettings]()
    var userId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The delegate is needed in order to set the firestore database with the same settings across multiple pages
        let delegate = UIApplication.shared.delegate as! AppDelegate
        // Get database from app delegate
        db = delegate.db

        userId = Auth.auth().currentUser!.uid
        print(userId)
        db!.collection("watchLocations").whereField("userId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                print("here")
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                print(documents)
                self.alertSettings = [AlertSettings]()
                for document in documents {
                    let setting = AlertSettings(alertSettings: document.data(), db: db!, id: document.documentID)
                    self.alertSettings.append(setting)
                    print(document)
                }
            
                self.tableView.reloadData()
                //print("Current cities in CA: \(cities)")
        }
        
        //alertSettings.append(alertSetting)
        
        //tableView.reloadData()

//        var bounds = tableView.bounds
//        bounds.size.height = tableView.contentSize.height
//        // You can add anything to the height now with bounds.size.height += something
//        tableView.bounds = bounds
        
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // If signed in stay on the page if not go back to login
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil) { // a user is signed in, do nothing
                print("USER SIGNED IN")
            } else { // no user signed in, go back to login screen
                print("NO USER SIGNED IN")
                self.performSegue(withIdentifier: "mapsToSignInSegue", sender: self)
                //TODO: Should listeners be detatched here?
            }
        }
    }
    
    func didSave(_ cell: AlertTableViewCell) {
        print("Did Save Called")
        
        let alertSetting = AlertSettings(db: db!)
        
        // Name Setting
        print("Name Settings")
        if cell.nameInput.text != nil && cell.nameInput.text != "" {
            alertSetting.name = cell.nameInput.text!
        } else {
            let alert = UIAlertController(title: "Name Empty", message: "Name must not be empty.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        // Push Notification Settings
        print("Push Settings")
        alertSetting.pushNotificationsEnabled = cell.pushNotificationsSwitch.isOn
        alertSetting.userId = userId
        
        // Texts Settings
        print("Text Settings")
        alertSetting.textsEnabled = cell.textNotificationsSwitch.isOn
        if cell.textNumber1Input.text != nil && cell.textNumber1Input.text != "" {
            alertSetting.textNumbers.append(cell.textNumber1Input.text!)
        }
        if cell.textNumber2Input.text != nil && cell.textNumber2Input.text != "" {
            alertSetting.textNumbers.append(cell.textNumber2Input.text!)
        }
        if cell.textNumber3Input.text != nil && cell.textNumber3Input.text != "" {
            alertSetting.textNumbers.append(cell.textNumber3Input.text!)
        }
        if alertSetting.textsEnabled && alertSetting.textNumbers.count <= 0 {
            let alert = UIAlertController(title: "Text Error", message: "If texts are turned on, you must enter a phone number.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Calls Settings
        print("Call Settings")
        alertSetting.callsEnabled = cell.callNotificationsSwitch.isOn
        if cell.callNumber1Input.text != nil && cell.callNumber1Input.text != "" {
            alertSetting.callNumbers.append(cell.callNumber1Input.text!)
        }
        if cell.callNumber2Input.text != nil && cell.callNumber2Input.text != "" {
            alertSetting.callNumbers.append(cell.callNumber2Input.text!)
        }
        if cell.callNumber3Input.text != nil && cell.callNumber3Input.text != "" {
            alertSetting.callNumbers.append(cell.callNumber3Input.text!)
        }
        if alertSetting.callsEnabled && alertSetting.callNumbers.count <= 0 {
            let alert = UIAlertController(title: "Call Error", message: "If calls are turned on, you must enter a phone number.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Emails Settings
        print("Email Settings")
        alertSetting.emailsEnabled = cell.emailNotificationsSwitch.isOn
        if cell.email1Input.text != nil && cell.email1Input.text != "" {
            alertSetting.emails.append(cell.email1Input.text!)
        }
        if cell.email2Input.text != nil && cell.email2Input.text != "" {
            alertSetting.emails.append(cell.email2Input.text!)
        }
        if cell.email3Input.text != nil && cell.email3Input.text != "" {
            alertSetting.emails.append(cell.email3Input.text!)
        }
        if alertSetting.emailsEnabled && alertSetting.emails.count <= 0 {
            let alert = UIAlertController(title: "Email Error", message: "If emails are turned on, you must enter an email.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Location Setting
        print("Location Settings")
        if cell.latitudeInput.text != nil && cell.latitudeInput.text != "" && cell.longitudeInput.text != nil && cell.longitudeInput.text != "" {
            if let lat = Double(cell.latitudeInput.text!), let lon = Double(cell.longitudeInput.text!) {
                if lat <= 90 && lat >= -90 && lon <= 180 && lon >= -180 {
                    alertSetting.coordinates = GeoPoint(latitude: lat, longitude: lon)
                } else {
                    let alert = UIAlertController(title: "Latitude/Longitude Invalid", message: "Latitude must be between -90 and 90 and Longitude must be between -180 and 180.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            } else {
                let alert = UIAlertController(title: "Latitude/Longitude Not Numbers", message: "Latitude and Longitude must be numbers.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        } else {
            let alert = UIAlertController(title: "Latitude/Longitude Empty", message: "Latitude and Longitude cannot be empty.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        print("Saving to firbase")
        alertSetting.saveToFirebase(sender: self)
        
    }
    
    func removeCell(_ alertSetting: AlertSettings) {
        if let index = alertSettings.index(of: alertSetting) {
            alertSettings.remove(at: index)
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return alertSettings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AlertTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AlertTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        cell.alertDelegate = self
        
        let alertSetting = alertSettings[indexPath.row]
        
        // Setting push notificaiton settings
        cell.pushNotificationsSwitch.isOn = alertSetting.pushNotificationsEnabled
        
        // Setting name
        cell.nameInput.text = alertSetting.name
        
        // Setting text information
        cell.textNotificationsSwitch.isOn = alertSetting.textsEnabled
        if (alertSetting.textNumbers.count > 2) {
            cell.textNumber3Input.text = alertSetting.textNumbers[2]
        } else {
            cell.textNumber3Input.text = ""
        }
        if (alertSetting.textNumbers.count > 1) {
            cell.textNumber2Input.text = alertSetting.textNumbers[1]
        }  else {
            cell.textNumber2Input.text = ""
        }
        if (alertSetting.textNumbers.count > 0) {
            cell.textNumber1Input.text = alertSetting.textNumbers[0]
        } else {
            cell.textNumber1Input.text = ""
        }
        
        // Setting call information
        cell.callNotificationsSwitch.isOn = alertSetting.callsEnabled
        if (alertSetting.callNumbers.count > 2) {
            cell.callNumber3Input.text = alertSetting.callNumbers[2]
        } else {
            cell.callNumber3Input.text = ""
        }
        if (alertSetting.callNumbers.count > 1) {
            cell.callNumber2Input.text = alertSetting.callNumbers[1]
        } else {
            cell.callNumber2Input.text = ""
        }
        if (alertSetting.callNumbers.count > 0) {
            cell.callNumber1Input.text = alertSetting.callNumbers[0]
        } else {
            cell.callNumber1Input.text = ""
        }
        
        // Setting email information
        cell.emailNotificationsSwitch.isOn = alertSetting.emailsEnabled
        if (alertSetting.emails.count > 2) {
            cell.email3Input.text = alertSetting.emails[2]
        } else {
            cell.email3Input.text = ""
        }
        if (alertSetting.emails.count > 1) {
            cell.email2Input.text = alertSetting.emails[1]
        } else {
            cell.email2Input.text = ""
        }
        if (alertSetting.emails.count > 0) {
            cell.email1Input.text = alertSetting.emails[0]
        } else {
            cell.email1Input.text = ""
        }
        
        // Setting Location
        cell.latitudeInput.text = String(alertSetting.coordinates.latitude)
        cell.longitudeInput.text = String(alertSetting.coordinates.longitude)
        
        // Setting the alertSetting for reference to see if changes occur
        cell.alertSetting = alertSetting

        // Configure the cell...

        return cell
    }
    
    @IBAction func addAlertClicked(_ sender: Any) {
        let newAlertSetting = AlertSettings(db: db!)
        alertSettings.append(newAlertSetting)
        tableView.reloadData()
    }
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
