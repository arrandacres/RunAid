//
//  PendingAlertInterfaceController.swift
//  RunAidWatchApp Extension
//
//  Created by Arran Dacres on 27/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import WatchKit
import WatchConnectivity

class PendingAlertInterfaceController: WKInterfaceController {

    var wcSession: WCSession!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        
//        if let watchConnectionSession = context as? WCSession {
//            wcSession = watchConnectionSession
//            print("Pending Alert - WCSession established")
//        }
    }
    
    override func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        if let continueRun = message["UserOnRun"] as? Bool {
            if continueRun {
                DispatchQueue.main.async {
                    WKInterfaceController.reloadRootPageControllers(withNames: ["SOSView", "RunDetailsView", "CancelRunView"], contexts: [session, session, session], orientation: .horizontal, pageIndex: 1)
                }
            }
        }
    }
    
}
