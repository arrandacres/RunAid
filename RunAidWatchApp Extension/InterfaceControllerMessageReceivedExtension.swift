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
    
    //apple watch receives message function
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        let userOnRun = message["UserOnRun"] as? Bool
        if let continueRun = userOnRun{
            if continueRun {
                DispatchQueue.main.async {
                    self.pushController(withName: "RunDetailsView", context: nil)
                }
            }else{
                DispatchQueue.main.async {
                    self.popToRootController()
                }
            }
        }
    }
    
    
    
}
