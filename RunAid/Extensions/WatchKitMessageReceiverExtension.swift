//
//  WatchKitMessageReceiverExtension.swift
//  RunAid
//
//  Created by Arran Dacres on 01/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation
import WatchConnectivity
import UIKit

extension UIViewController: WCSessionDelegate {
    
    func setUpWatchConnection() -> WCSession{
        
        let watchConnectionSession = WCSession.default
        watchConnectionSession.delegate = self
        watchConnectionSession.activate()
        
        return watchConnectionSession
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //Connected Successfully
        //Send message to Apple Watch to confirm connection -> set up receiver on 'Please Connect Your Apple Watch to iOS device' screen -> dismisses view when message received -- so that mobile app is only accessible when connected to iOS device with app installed
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("Watch Session Became Inactive")
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        print("Watch Session Did Deactivate")
    }
    
    //Function utilised when message received from Apple Watch
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("iOS Data Received: ", message)
        if let message = message["Watch Message"] as? String {
            let alertView = self.CreateAlertWithActionButton(errorTitle: "Message From Watch", errorMessage: message)
            self.present(alertView, animated: true)
        }
    }
    
    
}
