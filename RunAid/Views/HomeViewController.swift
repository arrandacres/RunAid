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
        
        print("Home VC")
        print("Username: " + (user?.username)!)
        
        createUserDefaults(loggedInUsername: (user?.username)!)
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
            //self.createUserDefaults()
            return nil
        })
    }
    
    func createUserDefaults(loggedInUsername: String) {
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var userObject: RunAidUser = RunAidUser();
        userObject._username = user?.username
        
        dynamoDbObjectMapper.load(RunAidUser.self, hashKey: userObject._username, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else if let result = task.result as? RunAidUser {
                // Do something with task.result.
                userObject = result
                let defaults = UserDefaults.standard
                defaults.set(userObject._username, forKey: "Username")
                defaults.set(userObject._emailAddress, forKey: "EmailAddress")
                defaults.set(userObject._phoneNumber, forKey: "PhoneNumber")
                defaults.set(userObject._emergencyContacts, forKey: "EmergencyContacts")
                print("User Defaults saved")
                
            }
            return userObject
        })
        
//        let username = user?.username
//        print("Phone Number: " + getUser(username: username!))
//        let email = self.userAttributes?.filter { $0.name == "email"}.first?.value
//        let phoneNumber = self.userAttributes?.filter { $0.name == "phone_number"}.first?.value
//        let defaults = UserDefaults.standard
//
//        defaults.set(user?.username, forKey: "Username")
//        defaults.set(self.userAttributes?.filter { $0.name == "email"}.first?.value, forKey: "EmailAddress")
//        defaults.set(self.userAttributes?.filter { $0.name == "phone_number"}.first?.value, forKey: "PhoneNumber")
//        //defaults.set(emergencyContacts, forKey: "EmergencyContacts")
//        defaults.synchronize()
    }
    
    func getUser(username: String) -> String {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var userObject: RunAidUser = RunAidUser();
        userObject._username = username
        
        dynamoDbObjectMapper.load(RunAidUser.self, hashKey: userObject._username, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else if let result = task.result as? RunAidUser {
                // Do something with task.result.
                userObject = result
                print(result)
            }
            return userObject._phoneNumber
        })
        return String()
    }
}
