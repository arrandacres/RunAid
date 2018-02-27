//
//  AlertCreator+Extension.swift
//  RunAid
//
//  Created by Arran Dacres on 23/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
    
    func CreateAlertWithActionButton(errorTitle: String, errorMessage: String) -> UIAlertController{
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
        
        return alert
    }
}

