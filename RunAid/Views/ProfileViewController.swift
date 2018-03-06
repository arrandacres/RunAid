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


class ProfileViewController: UIViewController {
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    var wcSession : WCSession!
    var reachability:Reachability?
    
    @IBOutlet weak var UsernameLbl: UILabel!
    @IBOutlet weak var emailAddressLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reachability = Reachability.init()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let tabbar = tabBarController as! HomeViewController
        self.user = tabbar.user
        self.userAttributes = tabbar.userAttributes
        
        if((self.reachability!.connection) == .none){
            //set Username, Email Address, and PhoneNumber labels usign UserDefaults
            UsernameLbl.text = UserDefaults.standard.value(forKey: "Username") as? String
            emailAddressLbl.text = UserDefaults.standard.value(forKey: "EmailAddress") as? String
            phoneNumberLbl.text = UserDefaults.standard.value(forKey: "PhoneNumber") as? String
            
        }else{
            //set username, email address, and phone number using AWS Cognito user details
            UsernameLbl.text = self.user?.username
            emailAddressLbl.text = self.userAttributes?.filter { $0.name == "email"}.first?.value
            phoneNumberLbl.text = self.userAttributes?.filter { $0.name == "phone_number"}.first?.value
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wcSession = self.setUpWatchConnection()
    }
    
    @IBAction func SendMsg_Pressed(_ sender: Any) {
        
        wcSession.sendMessage(constructData(), replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //constructs dictionary of username and user details to send to Apple Watch
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
        let signOutAlert = UIAlertController(title: "Are you sure you want to log out?", message: "", preferredStyle: .alert)
        signOutAlert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        signOutAlert.addAction(UIAlertAction(title: "Yes", style: .default){ (action:UIAlertAction!) in
            self.user?.signOut()
            self.user?.getDetails()
        })
        self.present(signOutAlert, animated: true)
        
    }
}

