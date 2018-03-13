//
//  RunMonitoringInterfaceController.swift
//  RunAidWatchApp Extension
//
//  Created by Arran Dacres on 12/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import WatchKit
import WatchConnectivity

class RunMonitoringInterfaceController: WKInterfaceController {
    
    @IBOutlet var distanceLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    
    var wcSession: WCSession!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }
    
    //Apple Watch no longer connected to iPhone
    func sessionReachabilityDidChange(_ session: WCSession) {
    }
    
    override func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let userOnRun = message["UserOnRun"] as? Bool
        if let continueRun = userOnRun{
            if !continueRun {
                DispatchQueue.main.async {
                    self.popToRootController()
                }
            }
        }
        else{
            if let runDistance = message["RunDistance"] as? String {
                distanceLabel.setText(runDistance)
            }
            if let runTime = message["RunTime"] as? String {
                timeLabel.setText(runTime)
            }
        }
    }
}
