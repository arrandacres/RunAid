//
//  BorderedView.swift
//  RunAid
//
//  Created by Arran Dacres on 11/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedView: UIView {

    @IBInspectable var topBorderColour: UIColor = UIColor.clear {
        didSet{
            self.addBorder(side: .top, thickness: 3, color: topBorderColour, leftOffset: 15.0, rightOffset: 15.0)
        }
    }
    
    @IBInspectable var bottomBorderColour: UIColor = UIColor.clear {
        didSet{
            self.addBorder(side: .bottom, thickness: 3, color: bottomBorderColour)
        }
    }
    
}
