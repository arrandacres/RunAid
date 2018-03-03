//
//  UserRegistrationViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 23/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation
import UIKit
import AWSCognitoIdentityProvider
import AWSDynamoDB

class UserRegistrationViewController: UIViewController, AWSCognitoIdentityPasswordAuthentication {
    
    @IBOutlet weak var UsernameTxtField: UITextField!
    @IBOutlet weak var EmailAddrTxtField: UITextField!
    @IBOutlet weak var PhoneNumberTxtField: UITextField!
    @IBOutlet weak var PasswordTxtField: UITextField!
    @IBOutlet weak var ConfirmPasswordTxtField: UITextField!
    
    @IBOutlet weak var ExitBtn: UIButton!
    @IBOutlet weak var CreateAccountBtn: UIButton!
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenBackgroundTouched()
        
        //sets Create Account button to disabled and adds inputDidChange action to each text field
        self.CreateAccountBtn.isEnabled = false
        self.UsernameTxtField.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.EmailAddrTxtField.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.PhoneNumberTxtField.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.PasswordTxtField.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.ConfirmPasswordTxtField.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
    }
    
    //Sign up user using credentials from User Reg. View
    @IBAction func CreateAccountBtn_Pressed(_ sender: Any) {
        SignUpUser(userAttributes: GetUserCognitoCredentials())
    }
    
    //Create AWS Cognito user in User Pool
    func SignUpUser(userAttributes: [AWSCognitoIdentityUserAttributeType]){
        
        AppDelegate.getUserPool().signUp(UsernameTxtField.text!, password: PasswordTxtField.text!, userAttributes: userAttributes, validationData: nil ).continueWith{ (response) -> Any? in
            if response.error != nil {
                DispatchQueue.main.async {
                    let alertView = self.CreateAlertWithActionButton(errorTitle: "User Registration Error", errorMessage: ((response.error! as NSError).userInfo["message"] as? String)!)
                    self.present(alertView, animated: true)
                }
            } else {
                //user sign up successful - save user to DynamoDB
                self.SaveNewUser(user: self.createUserObject())
            }
            return nil
        }
    }
    
    //saves new user to DynamoDB RunAid table
    func SaveNewUser(user: RunAidUser) {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        //Save a new item
        dynamoDbObjectMapper.save(user, completionHandler: {
            (error: Error?) -> Void in
            if error != nil {
                let alert = self.CreateAlertWithActionButton(errorTitle: "User Save Error!", errorMessage: "Sorry there was an issue saving your details. Please retry user registration")
                self.present(alert, animated: true)
                return
            }

            //User succesfully created
            //display Account Created alert - when press 'OK' close registration view
            let alert = UIAlertController(title: "Account Created!", message: "Your account has been successfully created!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default){ (action:UIAlertAction!) in
                DispatchQueue.main.async {
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }})
            self.present(alert, animated: true)
        })
    }
    
    //creates RunAidUser object with attributes from user registration
    func createUserObject() -> RunAidUser{
        let userItem: RunAidUser = RunAidUser()
        
        userItem._username = UsernameTxtField.text
        userItem._deviceId = UIDevice.current.identifierForVendor?.uuidString
        userItem._emailAddress = EmailAddrTxtField.text
        userItem._phoneNumber = PhoneNumberTxtField.text
        
        return userItem
    }
    
    func createExampleEmergencyContacts() -> [[String:String]]{
        
        let contact1: [String:String] = ["userId":"Steve","deviceId":"steveDevice","phone number":"888"]
        let contact2: [String:String] = ["userId":"Terry","deviceId":"terryDevice","phone number":"777"]
        let contact3: [String:String] = ["userId":"Frank","deviceId":"frankDevice","phone number":"555"]
        return [contact1,contact2,contact3]
    }
    
    //Gets the user credentials from the text fields and returns array of AWSCognitoIdentityUserAttributeType
    func GetUserCognitoCredentials() -> [AWSCognitoIdentityUserAttributeType]{
        
        //let username = AWSCognitoIdentityUserAttributeType(name: "preferred_username", value: UsernameTxtField.text!)
        let emailAddress = AWSCognitoIdentityUserAttributeType(name: "email", value: EmailAddrTxtField.text!)
        let phoneNumber = AWSCognitoIdentityUserAttributeType(name: "phone_number", value: PhoneNumberTxtField.text!)
        
        return [emailAddress, phoneNumber]
    }
    
    //overriden getDetails method called by AWS
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.UsernameTxtField?.text == nil) {
                self.UsernameTxtField?.text = authenticationInput.lastKnownUsername
            }
        }
    }
    
    //overridden method called by AWS should user registration fail
    public func didCompleteStepWithError(_ error: Error?) {
        
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = self.CreateAlertWithActionButton(errorTitle: (error.userInfo["__type"] as? String)!, errorMessage: (error.userInfo["message"] as? String)!)
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.dismiss(animated: true, completion: {
                    self.UsernameTxtField?.text = nil
                    self.PasswordTxtField?.text = nil
                })
            }
        }
    }
    
    //close registration view when cross pressed - navigate back to Login View
    @IBAction func crossBtn_pressed(_ sender: AnyObject) {
        
        DispatchQueue.main.async {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
