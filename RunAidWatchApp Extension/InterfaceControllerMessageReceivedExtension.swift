//
//  InterfaceControllerMessageReceivedExtension.swift
//  RunAidWatchApp Extension
//
//  Created by Arran Dacres on 13/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import WatchKit
import WatchConnectivity

extension WKInterfaceController: WCSessionDelegate {
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Connected")
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        if !session.isReachable {
            print("Watch Connection Session Not Reachable")
        }
    }
    //apple watch receives message function
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        let userOnRun = message["UserOnRun"] as? Bool
        if let continueRun = userOnRun{
            if continueRun {
                DispatchQueue.main.async {
                    WKInterfaceController.reloadRootPageControllers(withNames: ["SOSView", "RunDetailsView", "CancelRunView"], contexts: [session, session, session], orientation: .horizontal, pageIndex: 1)
                }
            }else{
                DispatchQueue.main.async {
                    WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "StartRunInterfaceController", context: session)])
                }
            }
        }
    }
    
    
    
}
