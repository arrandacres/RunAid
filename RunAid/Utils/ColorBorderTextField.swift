//
//  ColorBorderTextField.swift
//  RunAid
//
//  Created by Arran Dacres on 27/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation
import UIKit

class ColorBorderTextField: UITextField {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setBorderColor()
    }
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.setBorderColor()
    }
    func setBorderColor(){
        self.layer.borderColor = UIColor.darkGray.cgColor // color you want
        self.layer.borderWidth = 1
        self.layer.cornerRadius = frame.size.height / 5
        // code which is common for all text fields
    }
}
