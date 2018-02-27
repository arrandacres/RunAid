//
//  HomeViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 26/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

class HomeViewController: UITabBarController {
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //required for login -> redirects to login view
        self.getCurrentUser()
        //self.user = self.getCurrentUser()
        // self.userAttributes = self.getCurrentUserAttributes(currentUser: self.user!)
    }
    
    func getCurrentUser() {
        user = AppDelegate.getUserPool().currentUser()!
        user?.getDetails().continueOnSuccessWith(block: { (task) -> Any? in
            guard task.result != nil else {
                return nil
            }
            self.userAttributes = task.result?.userAttributes
            self.userAttributes?.forEach({ (attribute) in
                print("Name: " + attribute.name! + "  Value: " + attribute.value!)
            })
            return nil
        })
    }
    
    func getCurrentUserAttributes(currentUser : AWSCognitoIdentityUser) -> [AWSCognitoIdentityProviderAttributeType]{
        currentUser.getDetails().continueOnSuccessWith(block: { (task) -> Any? in
            guard task.result != nil else {
                return nil
            }
            let attributes = task.result?.userAttributes
            
            attributes?.forEach({ (attribute) in
                print("Name: " + attribute.name! + "  Value: " + attribute.value!)
            })
            
            return attributes
        })
        return [AWSCognitoIdentityProviderAttributeType]()
    }
}
