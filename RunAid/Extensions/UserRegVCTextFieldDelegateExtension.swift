//
//  UserRegVCTextFieldDelegateExtension.swift
//  RunAid
//
//  Created by Arran Dacres on 03/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation
import UIKit

//When user presses return key in Username field automatically jumps to password field etc.
//code interpreted from: https://cocoacasts.com/five-simple-tips-to-make-user-friendly-forms-on-ios
extension UserRegistrationViewController: UITextFieldDelegate{
    
    //When return key pressed - set focus to next text field
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
    
    //move up view 200px when text field being edited i.e. keyboard is showing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(edittedTextField: textField, distanceToMove: 200, upwards: true)
    }
    
    //move down view 200px when text field stop being edited i.e. keyboard is not showing
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(edittedTextField: textField, distanceToMove: 200, upwards: false)
    }
    
    //move text by given distance(px) for given direction
    func moveTextField(edittedTextField: UITextField, distanceToMove: Int, upwards: Bool){
        UIView.beginAnimations("moveTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(0.3)
        self.ExitBtn.frame = self.ExitBtn.frame.offsetBy(dx: 0, dy: CGFloat(upwards ? distanceToMove : -distanceToMove))
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: CGFloat(upwards ? -distanceToMove : distanceToMove))
        UIView.commitAnimations()
    }
    
    //if any of the text field are empty or if the entered password doesn't match the confirm passowrd text then CreateAccount button is disabled
    //otherwise button is clickable
    @objc func inputDidChange(_ sender:AnyObject) {
        
        if ((self.UsernameTxtField?.text?.isEmpty)! || (self.EmailAddrTxtField?.text?.isEmpty)! || (self.PhoneNumberTxtField?.text?.isEmpty)! || (self.PasswordTxtField?.text?.isEmpty)! || (self.ConfirmPasswordTxtField?.text?.isEmpty)! || self.PasswordTxtField?.text != self.ConfirmPasswordTxtField?.text) {
            self.CreateAccountBtn?.isEnabled = false
        } else {
            self.CreateAccountBtn?.isEnabled = true
        }
    }
}
