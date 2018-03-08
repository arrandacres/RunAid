//
//  RoundedView.swift
//  RunAid
//
//  Created by Arran Dacres on 06/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit

@IBDesignable class RoundedView: UIView {


    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

}
