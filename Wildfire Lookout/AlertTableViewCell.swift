//
//  AlertTableViewCell.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 3/9/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import FirebaseFirestore

protocol AlertCellDelegate: class {
    func didSave(_ cell: AlertTableViewCell)
    func removeCell(_ alertSetting: AlertSettings)
}

class AlertTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameInput: UITextField!
    
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    
    @IBOutlet weak var textNotificationsSwitch: UISwitch!
    @IBOutlet weak var textNumber1Label: UITextView!
    @IBOutlet weak var textNumber1Input: UITextField!
    @IBOutlet weak var textNumber2Label: UITextView!
    @IBOutlet weak var textNumber2Input: UITextField!
    @IBOutlet weak var textNumber3Label: UITextView!
    @IBOutlet weak var textNumber3Input: UITextField!
    
    @IBOutlet weak var callNotificationsSwitch: UISwitch!
    @IBOutlet weak var callNumber1Label: UITextView!
    @IBOutlet weak var callNumber1Input: UITextField!
    @IBOutlet weak var callNumber2Label: UITextView!
    @IBOutlet weak var callNumber2Input: UITextField!
    @IBOutlet weak var callNumber3Label: UITextView!
    @IBOutlet weak var callNumber3Input: UITextField!
    
    @IBOutlet weak var emailNotificationsSwitch: UISwitch!
    @IBOutlet weak var email1Label: UITextView!
    @IBOutlet weak var email1Input: UITextField!
    @IBOutlet weak var email2Label: UITextView!
    @IBOutlet weak var email2Input: UITextField!
    @IBOutlet weak var email3Label: UITextView!
    @IBOutlet weak var email3Input: UITextField!
    
    @IBOutlet weak var latitudeInput: UITextField!
    @IBOutlet weak var longitudeInput: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    weak var alertDelegate: AlertCellDelegate?
    
    var alertSetting: AlertSettings?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func checkSaved() {
        let newAlertSetting = AlertSettings(db: db!)
        
        // Name
        newAlertSetting.name = nameInput.text!
        
        // Push notifications Settings
        newAlertSetting.pushNotificationsEnabled = pushNotificationsSwitch.isOn
        newAlertSetting.userId = alertSetting!.userId
        
        // Texts Settings
        newAlertSetting.textsEnabled = textNotificationsSwitch.isOn
        if textNumber1Input.text != nil && textNumber1Input.text != "" {
            newAlertSetting.textNumbers.append(textNumber1Input.text!)
        }
        if textNumber2Input.text != nil && textNumber2Input.text != "" {
            newAlertSetting.textNumbers.append(textNumber2Input.text!)
        }
        if textNumber3Input.text != nil && textNumber3Input.text != "" {
            newAlertSetting.textNumbers.append(textNumber3Input.text!)
        }
        
        // Calls Settings
        newAlertSetting.callsEnabled = callNotificationsSwitch.isOn
        if callNumber1Input.text != nil && callNumber1Input.text != "" {
            newAlertSetting.callNumbers.append(callNumber1Input.text!)
        }
        if callNumber2Input.text != nil && callNumber2Input.text != "" {
            newAlertSetting.callNumbers.append(callNumber2Input.text!)
        }
        if callNumber3Input.text != nil && callNumber3Input.text != "" {
            newAlertSetting.callNumbers.append(callNumber3Input.text!)
        }
        
        // Emails Settings
        newAlertSetting.emailsEnabled = emailNotificationsSwitch.isOn
        if email1Input.text != nil && email1Input.text != "" {
            newAlertSetting.emails.append(email1Input.text!)
        }
        if email2Input.text != nil && email2Input.text != "" {
            newAlertSetting.emails.append(email2Input.text!)
        }
        if email3Input.text != nil && email3Input.text != "" {
            newAlertSetting.emails.append(email3Input.text!)
        }
        
        // Location Setting
        if let lat = Double(latitudeInput.text!), let lon = Double(longitudeInput.text!) {
            newAlertSetting.coordinates = GeoPoint(latitude: lat, longitude: lon)
        } else {
            newAlertSetting.coordinates = GeoPoint(latitude: 0.0, longitude: 0.0)
        }
        
        if (newAlertSetting.isEqual(alertSetting)) {
            print("deactivate save")
            saveButton.isEnabled = false
        } else {
            print("activate save")
            saveButton.isEnabled = true
        }
    }
    
    @IBAction func editingEnded(_ sender: Any) {
        checkSaved()
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        print("Save clicked")
        alertDelegate!.didSave(self)
    }
    
    @IBAction func removeButtonClicked(_ sender: Any) {
        print("Remove clicked")
        alertDelegate!.removeCell(alertSetting!)
    }
    
}
