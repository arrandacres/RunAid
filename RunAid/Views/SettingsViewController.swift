//
//  SecondViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 21/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import WatchConnectivity
import MapKit
import MessageUI

class SettingsViewController: UIViewController {
    
    var wcSession : WCSession!
    private let smsManager = EmergencyAlertSmsManager()
    
    private var lastKnownLocation : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wcSession = self.setUpWatchConnection()
        
        self.lastKnownLocation = CLLocation(latitude: 54.858541, longitude: -1.479860)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "sendAlertSegue" {
            let alertVC = segue.destination as! EmergencyContactsAlertViewController
            alertVC.alertType = .LocationGoal
            alertVC.emergencyAlertRequested = { (requested) in
                //if the alert view controller has requested an emergency alert
                if requested {
                    self.showComposeMessageViewController()
                }
            }
        }
    }
    
    private func showComposeMessageViewController() {
        //if can create a SMS Message compose VC
        if self.smsManager.deviceCanSendSMS(){
            if let messageComposeVC = self.smsManager.getMessageComposeViewController(messageRecipients: getUserEmergencyContacts(), lastKnownLocation: self.lastKnownLocation!) {
                self.present(messageComposeVC, animated: true)
            }
        }else{
            //if user's device cannot send text messages; show alert
            let alert = UIAlertController(title: "Cannot send SMS Message", message: "Your device cannot send text messages.", preferredStyle: .alert)
            //custom action - dismisses both alertVCs
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //gets the user's emergency contact phone number stored in UserDefaults
    private func getUserEmergencyContacts() -> [String] {
        
        var contactPhoneNumbers = [String]()
        
        if let emergencyContacts = (UserDefaults.standard.value(forKey: "EmergencyContacts") as? [[String:String]]) {
            for contact in emergencyContacts {
                if let phoneNumber = contact["phone number"] {
                    contactPhoneNumbers.append(phoneNumber)
                }
            }
        }
        return contactPhoneNumbers
    }
    
}

