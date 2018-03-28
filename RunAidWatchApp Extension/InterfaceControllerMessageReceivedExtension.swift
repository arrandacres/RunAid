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
        
        if let continueRun = message["UserOnRun"] as? Bool {
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
        
        if let sendingAlert = message["SendingAlert"] as? Bool {
            if sendingAlert {
                //navigate to 'sending alert' interface
                DispatchQueue.main.async {
                    WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "SendingAlertInterface", context: session)])
                }
            }else {
                DispatchQueue.main.async {
                    WKInterfaceController.reloadRootPageControllers(withNames: ["SOSView", "RunDetailsView", "CancelRunView"], contexts: [session, session, session], orientation: .horizontal, pageIndex: 1)
                }
            }
        }
    }
    
    
    
}
