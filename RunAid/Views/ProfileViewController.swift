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
import AWSDynamoDB

class ProfileViewController: UIViewController {
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    var wcSession : WCSession!
    
    @IBOutlet weak var UsernameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wcSession = self.setUpWatchConnection()
        
        let tabbar = tabBarController as! HomeViewController
        self.user = tabbar.user
        self.userAttributes = tabbar.userAttributes
        
        UsernameLbl.text = self.userAttributes?.filter { $0.name == "email"}.first?.value
    }
    
    @IBAction func readEmergencyContacts(_ sender: Any) {
        let emergencyContacts = getEmergencyContacts()
    }

    func getEmergencyContacts() -> [[String:String]]{
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var userObject: RunAidUser = RunAidUser();
        userObject._username = user?.username

        dynamoDbObjectMapper.load(RunAidUser.self, hashKey: "Bob", rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
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

