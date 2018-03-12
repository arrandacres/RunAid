//
//  CircularButton.swift
//  RunAid
//
//  Created by Arran Dacres on 10/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit

@IBDesignable
class CircularButton: UIButton {

    @IBInspectable var radius: CGFloat = 0 {
        didSet{
            self.layer.cornerRadius = radius
        }
    }

}
