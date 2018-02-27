//
//  RoundedButton.swift
//  MobileDevEncrypt
//
//  Created by Arran Dacres on 17/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class RoundedButton: UIButton{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    @IBInspectable var roundedCorners: Bool = false{
        didSet{
            updateCornerRadius()
        }
    }
    
    func updateCornerRadius(){
        layer.cornerRadius = roundedCorners ? frame.size.height / 3 : 0
    }
}
