//
//  RunHomeViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 01/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import Foundation
import WatchConnectivity
import AWSCognitoIdentityProvider
import AWSDynamoDB

class RunHomeViewController: UIViewController {
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    var wcSession : WCSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabbar = tabBarController as! HomeViewController
        //move to ViewWillAppear during testing
        self.user = tabbar.user
        self.userAttributes = tabbar.userAttributes
        //setup watch connection (if available)
        wcSession = self.setUpWatchConnection()
        //createUserDefaults()
    }
    
    func createUserDefaults() {
        UserDefaults.standard.set(self.user?.username, forKey: "Username")
        UserDefaults.standard.set(self.userAttributes?.filter { $0.name == "email"}.first?.value, forKey: "EmailAddress")
        UserDefaults.standard.set(self.userAttributes?.filter{ $0.name == "phone_number"}.first?.value, forKey: "PhoneNumber")
        UserDefaults.standard.set(getEmergencyContacts(), forKey: "EmergencyContacts")
        UserDefaults.standard.synchronize()
    }
    
    func getEmergencyContacts() -> [[String:String]]{
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var userObject: RunAidUser = RunAidUser();
        userObject._username = user?.username
        
        dynamoDbObjectMapper.load(RunAidUser.self, hashKey: userObject._username, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else if let result = task.result as? RunAidUser {
                // Do something with task.result.
                userObject = result
                print(result)
            }
            return userObject._emergencyContacts
        })
        return [[String:String]]()
    }
    
    
}
