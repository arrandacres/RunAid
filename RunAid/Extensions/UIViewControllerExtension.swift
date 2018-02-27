//
//  UIViewControllerExtension.swift
//  MobileDevEncrypt
//
//  Created by Arran Dacres on 17/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation
import UIKit

//Code from https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift from user Esqarrouth
public extension UIViewController {
    func hideKeyboardWhenBackgroundTouched() {
        let tapped : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tapped.cancelsTouchesInView = false
        view.addGestureRecognizer(tapped)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
