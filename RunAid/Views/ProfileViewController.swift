//
//  FirstViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 21/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import WatchConnectivity

class ProfileViewController: UIViewController, WCSessionDelegate {
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    var wcSession : WCSession!
    
    @IBOutlet weak var UsernameLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabbar = tabBarController as! HomeViewController
        self.user = tabbar.user
        self.userAttributes = tabbar.userAttributes
        
        UsernameLbl.text = self.userAttributes?.filter { $0.name == "email"}.first?.value
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }
    
    @IBAction func SendMsg_Pressed(_ sender: Any) {
        
        wcSession.sendMessage(constructData(), replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //constructs dictionary of username and user details
    private func constructData() -> [String:AnyObject] {
        
        var dataDictionary = [String: AnyObject]()
        dataDictionary["Username"] = user?.username as AnyObject
        if let attributes = userAttributes
        {
            for attribute in attributes {
                dataDictionary[attribute.name!] = attribute.value as AnyObject
            }
        }
        return dataDictionary
    }
    
    //Logs user out and return to the Login View
    @IBAction func logoutBtn_pressed(_ sender: AnyObject) {
        user?.signOut()
        user?.getDetails()
    }
    
    //Function utilised when message received from Apple Watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("iOS Data Received: ", message)
        if let message = message["Watch Message"] as? String {
            let alertView = self.CreateAlertWithActionButton(errorTitle: "Message From Watch", errorMessage: message)
            self.present(alertView, animated: true)
        }
    }
    
    //Methods required to be implemented by WCSessionDelegate
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
}

