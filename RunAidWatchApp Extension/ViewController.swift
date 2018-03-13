//
//  ViewController.swift
//  RunAidWatchApp Extension
//
//  Created by Arran Dacres on 11/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ViewController: WKInterfaceController {

    var wcSession: WCSession!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }
    
    override func didAppear() {
        wcSession.delegate = self
    }
    
    
}
