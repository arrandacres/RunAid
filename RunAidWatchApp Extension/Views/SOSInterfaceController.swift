//
//  SOSInterfaceController.swift
//  RunAidWatchApp Extension
//
//  Created by Arran Dacres on 12/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import WatchKit
import WatchConnectivity

class SOSInterfaceController: WKInterfaceController {

    var wcSession: WCSession!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let watchConnectionSession = context as? WCSession {
            wcSession = watchConnectionSession
            print("Send S.O.S - WCSession established")
        }
    }
    
    @IBAction func send_sos_pressed() {
        print("Send S.O.S Alert Message Sent to iPhone")
        wcSession.sendMessage(["SendSOSAlert":true], replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "StartRunInterfaceController", context: self.wcSession)])
        }
    }
}
