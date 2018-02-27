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

class UserRegistrationViewController: UIViewController, AWSCognitoIdentityPasswordAuthentication {
    
    @IBOutlet weak var UsernameTxtField: UITextField!
    @IBOutlet weak var EmailAddrTxtField: UITextField!
    @IBOutlet weak var PhoneNumberTxtField: UITextField!
    @IBOutlet weak var PasswordTxtField: UITextField!
    @IBOutlet weak var ConfirmPasswordTxtField: UITextField!
    
    @IBOutlet weak var CreateAccountBtn: UIButton!
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                //user sign up successful
                
                //self.user = response.result!.user
                
                //let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.UsernameTxtField!.text!, password: self.PasswordTxtField!.text! )
                //self.passwordAuthenticationCompletion?.set(result: authDetails)
                
                DispatchQueue.main.async {
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
            return nil
        }
    }
    
    //Gets the user credentials from the text fields and returns array of AWSCognitoIdentityUserAttributeType
    func GetUserCognitoCredentials() -> [AWSCognitoIdentityUserAttributeType]{
        
        //let username = AWSCognitoIdentityUserAttributeType(name: "preferred_username", value: UsernameTxtField.text!)
        let emailAddress = AWSCognitoIdentityUserAttributeType(name: "email", value: EmailAddrTxtField.text!)
        let phoneNumber = AWSCognitoIdentityUserAttributeType(name: "phone_number", value: PhoneNumberTxtField.text!)
        
        return [emailAddress, phoneNumber]
    }
    
    //if any of the text field are empty or if the entered password doesn't match the confirm passowrd text then CreateAccount button is disabled
    //otherwise button is clickable
    @objc func inputDidChange(_ sender:AnyObject) {
        if (self.UsernameTxtField?.text == nil || self.EmailAddrTxtField?.text == nil || self.PhoneNumberTxtField?.text == nil || self.PasswordTxtField?.text == nil || self.ConfirmPasswordTxtField?.text == nil) {
            self.CreateAccountBtn?.isEnabled = false
        } else if(self.PasswordTxtField?.text != self.ConfirmPasswordTxtField?.text){
            self.CreateAccountBtn?.isEnabled = false
        } else {
            self.CreateAccountBtn?.isEnabled = true
        }
    }
    
    //Called by AWS -
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.UsernameTxtField?.text == nil) {
                self.UsernameTxtField?.text = authenticationInput.lastKnownUsername
            }
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.dismiss(animated: true, completion: {
                    self.UsernameTxtField?.text = nil
                    self.PasswordTxtField?.text = nil
                })
            }
        }
    }
    
}

//When user presses return key in Username field automatically jumps to password field
//code interpreted from: https://cocoacasts.com/five-simple-tips-to-make-user-friendly-forms-on-ios
extension UserRegistrationViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case UsernameTxtField:
            EmailAddrTxtField.becomeFirstResponder()
        case EmailAddrTxtField:
            PhoneNumberTxtField.becomeFirstResponder()
        case PhoneNumberTxtField:
            PasswordTxtField.becomeFirstResponder()
        case PasswordTxtField:
            ConfirmPasswordTxtField.becomeFirstResponder()
        default: ConfirmPasswordTxtField.resignFirstResponder()
        }
        return true
    }
}

