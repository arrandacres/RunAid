//
//  HomeViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 26/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider
import AWSDynamoDB

class HomeViewController: UITabBarController {
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    var initialLauch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set default tab
                if initialLauch == true {
                    initialLauch = false
                    self.selectedIndex = 1 //Run Home Tab
                }
        
        //required for login -> redirects to login view
        self.getCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        user = AppDelegate.getUserPool().currentUser()!
    }
    
    //Get current AWSCognitoIdentityUser object from UserPool
    //Gets the details of said user - if successful assign attributes to userAttributes variable
    func getCurrentUser() {
        user = AppDelegate.getUserPool().currentUser()!
        user?.getDetails().continueOnSuccessWith(block: { (task) -> Any? in
            guard task.result != nil else {
                return nil
            }
            self.userAttributes = task.result?.userAttributes
            return nil
        })
        
//        let defaults = UserDefaults.standard
//        defaults.set("Arran1", forKey: "Username")
//        defaults.set("arran.dacres@gmail.com", forKey: "EmailAddress")
//        defaults.set("+44712744422", forKey: "PhoneNumber")
//        defaults.set([[String:String]](), forKey: "EmergencyContacts")
    }
}
