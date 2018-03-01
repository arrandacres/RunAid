//
//  RunHomeViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 01/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import Foundation
import WatchConnectivity

class RunHomeViewController: UIViewController {
    
    var wcSession : WCSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wcSession = self.setUpWatchConnection()
    }
    
    
}
