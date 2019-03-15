//
//  AlertsViewController.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 3/14/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseFirestore
import FirebaseAuth

class AlertsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var alertTable: UITableView!
    
    var alerts = [AlertSettings]()
    // The firestore database
    var db:Firestore? = nil
    var userId = ""
    var alertNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // The delegate is needed in order to set the firestore database with the same settings across multiple pages
        let delegate = UIApplication.shared.delegate as! AppDelegate
        // Get database from app delegate
        db = delegate.db
        
        // Setting up the alert table
        alertTable.delegate = self
        alertTable.dataSource = self
        
        // Getting the alerts for this user from firebase
        userId = Auth.auth().currentUser!.uid
        db!.collection("watchLocations").whereField("userId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                var newSettings = [AlertSettings]()
                var newAlertNames = [String]()
                var bounds = GMSCoordinateBounds()
                for document in documents {
                    let setting = AlertSettings(alertSettings: document.data(), db: self.db!, id: document.documentID)
                    
                    newSettings.append(setting)
                    newAlertNames.append(setting.name)
                    
                    let location = setting.coordinates.locationValue().coordinate
                    let marker = GMSMarker()
                    marker.position = location
                    marker.map = self.mapView
                    marker.title = setting.name
                    bounds = bounds.includingCoordinate(location)
                }
                self.alerts = newSettings
                self.alertNames = newAlertNames
                
                // Adjust bounds to include all map points
                self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 50.0 , left: 50.0 ,bottom: 50.0 ,right: 50.0)))
                
                self.alertTable.reloadData()
                //print("Current cities in CA: \(cities)")
        }
        
        // Add the add button
        let button = UIBarButtonItem(title: "Add Alert", style: UIBarButtonItem.Style.plain, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = button
        // Do any additional setup after loading the view.
    }
    
    @objc func addButtonTapped() {
        if let setAlertSettingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetAlertSettings") as? SetAlertSettingsViewController {
            let alertSettings = AlertSettings(db: db!)
            alertSettings.userId = userId
            setAlertSettingVC.alertSetting = alertSettings
            if let navigator = navigationController {
                navigator.pushViewController(setAlertSettingVC, animated: true)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell") else {
                return UITableViewCell(style: .default, reuseIdentifier: "alertCell")
            }
            return cell
        }()
        let name = self.alerts[indexPath.row].name
        print(name)
        cell.textLabel?.text = name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Create the new view controller and push it onto the navigation controller
        if let setAlertSettingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetAlertSettings") as? SetAlertSettingsViewController {
            setAlertSettingVC.alertSetting = alerts[indexPath.row]
            if let navigator = navigationController {
                navigator.pushViewController(setAlertSettingVC, animated: true)
            }
        }
    }
}
