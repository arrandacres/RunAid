//
//  smsManager.swift
//  RunAid
//
//  Created by Arran Dacres on 18/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation
import MessageUI
import MapKit

class EmergencyAlertSmsManager: NSObject, MFMessageComposeViewControllerDelegate {
    
    var messageComposeVC: MFMessageComposeViewController?
    var textSuccessfullySent = false
    
    //construct Message Compose View Controller used to send messages
    func getMessageComposeViewController(messageRecipients: [String], lastKnownLocation: CLLocation) -> MFMessageComposeViewController? {
        
        let messageComposeViewController = MFMessageComposeViewController()
        messageComposeViewController.messageComposeDelegate = self
        //recipients' phone numbers
        messageComposeViewController.recipients = messageRecipients
        
        if MFMessageComposeViewController.canSendSubject(){
            messageComposeViewController.subject = "RunAid Emergency Alert"
        }
        messageComposeViewController.body = constructSMSMessage(lastKnownLocation: lastKnownLocation)
        
        self.messageComposeVC = messageComposeViewController
        
        return messageComposeViewController
    }
    
    func deviceCanSendSMS() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func isTextSuccessfullySent() -> Bool {
        return textSuccessfullySent
    }
    
    //construct the alert SMS body using user last known location
    func constructSMSMessage(lastKnownLocation: CLLocation) -> String {
        
        let locationURL = "http://maps.apple.com/?q=\(lastKnownLocation.coordinate.latitude),\(lastKnownLocation.coordinate.longitude)"
        
        return "RunAid user \(UserDefaults.standard.value(forKey: "Username")!) has sent out an emergency alert. Their last known location is \(locationURL)"
    }
    
    //delegate function - called upon the result of the compose message vc; sent, failed, or cancelled
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue:
            //if the message is cancelled by the user dismiss the controller
            controller.dismiss(animated: true)
        case MessageComposeResult.sent.rawValue:
            textSuccessfullySent = true
            controller.dismiss(animated: true)
        case MessageComposeResult.failed.rawValue:
            print("Message Failed")
        default:
            controller.dismiss(animated: true)
        }
    }
}
