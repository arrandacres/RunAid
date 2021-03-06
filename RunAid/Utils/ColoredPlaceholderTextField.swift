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
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 182, green: 181, blue:182, alpha:0.3)])
    }
}
