//
//  AlertSettings.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 3/12/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import FirebaseFirestore

// PAlert Settings holds information neccessary to hold and access alert settings from the watchLocations db
class AlertSettings: NSObject {
    var pushNotificationsEnabled: Bool
    var textsEnabled: Bool
    var callsEnabled: Bool
    var emailsEnabled: Bool
    var textNumbers: [String]
    var callNumbers: [String]
    var emails: [String]
    var coordinates: GeoPoint
    var userId: String
    var name: String
    var db: Firestore
    var id: String
    
    init(alertSettings: [String: Any], db: Firestore, id: String) { // inits a perimeter from the object returned by firestore
        let alertSettingsData = alertSettings["d"] as? [String: Any] ?? [String: Any]()
        pushNotificationsEnabled = alertSettingsData["pushNotificationsEnabled"] as? Bool ?? false
        textsEnabled = alertSettingsData["textsEnabled"] as? Bool ?? false
        callsEnabled = alertSettingsData["callsEnabled"] as? Bool ?? false
        emailsEnabled = alertSettingsData["emailsEnabled"] as? Bool ?? false
        textNumbers = alertSettingsData["textNumbers"] as? [String] ?? [String]()
        callNumbers = alertSettingsData["callNumbers"] as? [String] ?? [String]()
        emails = alertSettingsData["emails"] as? [String] ?? [String]()
        coordinates = alertSettingsData["coordinates"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        userId = alertSettingsData["userId"] as? String ?? ""
        name = alertSettingsData["name"] as? String ?? ""
        self.db = db
        self.id = id
    }
    
    init(db: Firestore) {
        pushNotificationsEnabled = false
        textsEnabled = false
        callsEnabled = false
        emailsEnabled = false
        textNumbers = [String]()
        callNumbers = [String]()
        emails = [String]()
        coordinates = GeoPoint(latitude: 0.0, longitude: 0.0)
        userId = ""
        name = ""
        self.db = db
        self.id = ""
    }
    
    func saveToFirebase(sender: AlertTableViewController) {
        let dataMap = ["pushNotificationsEnabled": pushNotificationsEnabled,
                       "textsEnabled": textsEnabled,
                       "callsEnabled": callsEnabled,
                       "emailsEnabled": emailsEnabled,
                       "textNumbers": textNumbers,
                       "callNumbers": callNumbers,
                       "emails": emails,
                       "userId": userId,
                       "coordinates": coordinates,
                       "name": name] as [String : Any]
        let watchLocation = ["d": dataMap, "g": "", "l": coordinates, "userId": userId] as [String : Any]
        
        db.collection("watchLocations").document(userId + "_" + name).setData(watchLocation) { err in
            if let err = err {
                print("Error writing document: \(err)")
                let alert = UIAlertController(title: "Error Saving Alert", message: err.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                sender.present(alert, animated: true, completion: nil)
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func getFirebaseObject() -> [String: Any] {
        let dataMap = ["pushNotificationsEnabled": pushNotificationsEnabled,
                       "textsEnabled": textsEnabled,
                       "callsEnabled": callsEnabled,
                       "emailsEnabled": emailsEnabled,
                       "textNumbers": textNumbers,
                       "callNumbers": callNumbers,
                       "emails": emails,
                       "userId": userId,
                       "coordinates": coordinates,
                       "name": name] as [String : Any]
        let watchLocation = ["d": dataMap, "g": "", "l": coordinates, "userId": userId] as [String : Any]
        return watchLocation
    }
    
    override func isEqual(_ object: Any?) -> Bool { // Allows to test if a fire has already been loaded
        if let object = object as? AlertSettings {
            print(coordinates)
            print(object.coordinates)
            return pushNotificationsEnabled == object.pushNotificationsEnabled
                && textsEnabled == object.textsEnabled
                && callsEnabled == object.callsEnabled
                && emailsEnabled == object.emailsEnabled
                && textNumbers == object.textNumbers
                && callNumbers == object.callNumbers
                && emails == object.emails
                && coordinates == object.coordinates
                && userId == object.userId
                && name == object.name
        } else {
            return false
        }
    }
}
