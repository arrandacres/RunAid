//
//  ViewController.swift
//  RunAidWatchApp Extension
//
//  Created by Arran Dacres on 11/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import WatchKit
import WatchConnectivity
import HealthKit

class ViewController: WKInterfaceController {

    var wcSession: WCSession!
    
    let healthStore: HKHealthStore = HKHealthStore()
    let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }
    
    @IBAction func start_run_pressed() {

        WKInterfaceController.reloadRootPageControllers(withNames: ["SOSView", "RunDetailsView", "CancelRunView"], contexts: [wcSession], orientation: .horizontal, pageIndex: 1)
        wcSession.sendMessage(["BeginRun": true], replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    override func didAppear() {
        wcSession.delegate = self
    }
    
    
}
