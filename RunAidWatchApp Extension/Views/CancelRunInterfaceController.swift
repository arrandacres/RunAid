//
//  RunButtonsInterfaceController.swift
//  RunAidWatchApp Extension
//
//  Created by Arran Dacres on 12/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import WatchKit
import WatchConnectivity

class CancelRunInterfaceController: WKInterfaceController {
    
    var wcSession: WCSession!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let watchConnectionSession = context as? WCSession {
            wcSession = watchConnectionSession
            print("Cancel Run - WCSession established")
        }
    }
    
    @IBAction func cancel_run_pressed() {
        print("Cancel Message Sent")
        wcSession.sendMessage(["StopRun":true], replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
        DispatchQueue.main.async {
            WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "StartRunInterfaceController", context: self.wcSession)])
        }
    }
}
