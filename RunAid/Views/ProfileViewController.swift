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
        var testTableObject: TestTable = TestTable();
        testTableObject._userId = user?.username
        
        dynamoDbObjectMapper.load(TestTable.self, hashKey: "Bob", rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let result = task.result as? TestTable {
                // Do something with task.result.
                testTableObject = result
                print(result)
            }
            return testTableObject._emergencyContacts
        })
        return [[String:String]]()
    }
    
    @IBAction func createExampleUserBtn_pressed(_ sender: Any) {
        createExampleUser()
    }
    func createExampleUser() {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let userItem: TestTable = TestTable()
        
        //userItem._userId = user?.username
        userItem._userId = "Bob"
        userItem._deviceId = UIDevice.current.identifierForVendor?.uuidString
        userItem._emailAddress = userAttributes?.first(where: { (attribute) -> Bool in
            attribute.name == "email"
        })?.value
        userItem._phoneNumber = "1234"
        userItem._emergencyContacts = createExampleEmergencyContacts()
        
        
        //Save a new item
        dynamoDbObjectMapper.save(userItem, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
    }
    
    func createExampleEmergencyContacts() -> [[String:String]]{
        
        let contact1: [String:String] = ["userId":"Steve","deviceId":"steveDevice","phone number":"888"]
        let contact2: [String:String] = ["userId":"Terry","deviceId":"terryDevice","phone number":"777"]
        let contact3: [String:String] = ["userId":"Frank","deviceId":"frankDevice","phone number":"555"]
        return [contact1,contact2,contact3]
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
}

