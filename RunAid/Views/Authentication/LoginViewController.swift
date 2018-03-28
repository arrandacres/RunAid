//
//  LoginViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 22/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation
import UIKit
import AWSCognitoIdentityProvider
import AWSDynamoDB

class LoginViewController: UIViewController, AWSCognitoIdentityPasswordAuthentication {
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet var textFields = [UITextField]()
    
    //Globally declared AWSTaskCompletionSource used for Cognito auth
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var reachability:Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenBackgroundTouched()
        
        textFields.append(usernameTxtField)
        textFields.append(passwordTxtField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: Notification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    @IBAction func logBtn_Pressed(_ sender: AnyObject) {
        
        self.reachability = Reachability.init()
        //if not connected to the internet display alert, if they are connected then attempt login
        if((self.reachability!.connection) != .none){
            //as long as the username and password text fields are not empty
            if (self.usernameTxtField.text != nil && self.passwordTxtField.text != nil){
                //setup Cognito Authentication Credentials using username/password fields
                let awsCognitoAuthDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.usernameTxtField.text!, password: self.passwordTxtField.text!)
                self.passwordAuthenticationCompletion?.set(result: awsCognitoAuthDetails)
            }
        }else{
            let alertController = self.CreateAlertWithActionButton(errorTitle: "No Internet connection!", errorMessage: "Connect your device to the Internet to Login")
            self.present(alertController, animated: true, completion:  nil)
        }
    }
    
    @objc private func textDidChange(_ notification: Notification) {
        var formIsValid = true
        
        for textField in textFields {
            // Validate Text Field
            let (valid, _) = validate(textField)
            
            guard valid else {
                formIsValid = false
                break
            }
        }
        // Update Save Button
        loginBtn.isEnabled = formIsValid
    }
    
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        return (text.count > 0, "This field cannot be empty.")
    }
    
    func inputDidChange(_ sender:AnyObject) {
        if (self.usernameTxtField?.text != nil && self.passwordTxtField?.text != nil) {
            self.loginBtn?.isEnabled = true
        } else {
            self.loginBtn?.isEnabled = false
        }
    }
    
    //Called by AWS -
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameTxtField?.text == nil) {
                self.usernameTxtField?.text = authenticationInput.lastKnownUsername
            }
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = self.CreateAlertWithActionButton(errorTitle: (error.userInfo["__type"] as? String)!, errorMessage: (error.userInfo["message"] as? String)!)
                self.present(alertController, animated: true, completion:  nil)
            } else {
                
                let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
                var userObject: RunAidUser = RunAidUser();
                let defaults = UserDefaults.standard
                userObject._username = self.usernameTxtField.text!
                
                dynamoDbObjectMapper.load(RunAidUser.self, hashKey: userObject._username, rangeKey:nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>!) -> Any? in
                    if let error = task.error as NSError? {
                        print("The request failed. Error: \(error)")
                    } else if let result = task.result as? RunAidUser {
                        // Do something with task.result.
                        userObject = result
                        print("LOGIN RESULT")
                        print(result)
                        defaults.set(userObject._username, forKey: "Username")
                        defaults.set(userObject._emailAddress, forKey: "EmailAddress")
                        defaults.set(userObject._phoneNumber, forKey: "PhoneNumber")
                        defaults.set(userObject._emergencyContacts ?? [[String:String]](), forKey: "EmergencyContacts")
                        
                        self.usernameTxtField?.text = nil
                        self.passwordTxtField?.text = nil

                        sleep(UInt32(0.8))
                        self.dismiss(animated: true, completion: nil)
                    }
                    return nil
                })
            }
        }
    }
}

//When user presses return key in Username field automatically jumps to password field
//code interpreted from: https://cocoacasts.com/five-simple-tips-to-make-user-friendly-forms-on-ios
extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTxtField:
            passwordTxtField.becomeFirstResponder()
        default: passwordTxtField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(edittedTextField: textField, distanceToMove: 200, upwards: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(edittedTextField: textField, distanceToMove: 200, upwards: false)
    }
    
    func moveTextField(edittedTextField: UITextField, distanceToMove: Int, upwards: Bool){
        
        UIView.beginAnimations("moveTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(0.3)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: CGFloat(upwards ? -distanceToMove : distanceToMove))
        UIView.commitAnimations()
    }
}


