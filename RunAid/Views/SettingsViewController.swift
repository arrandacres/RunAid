//
//  SecondViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 21/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import WatchConnectivity
import MapKit
import MessageUI

class SettingsViewController: UIViewController {
    
    var wcSession : WCSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wcSession = self.setUpWatchConnection()
    }
}

