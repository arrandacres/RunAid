//
//  RunMonitoringInterfaceController.swift
//  RunAidWatchApp Extension
//
//  Created by Arran Dacres on 12/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import WatchKit
import WatchConnectivity
import HealthKit

class RunMonitoringInterfaceController: WKInterfaceController {
    
    @IBOutlet var distanceLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    
    let healthStore: HKHealthStore = HKHealthStore()
    let heartRateUnit: HKUnit = HKUnit(from: "count/min")
    let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    
    var wcSession: WCSession!
    var workoutSession: HKWorkoutSession?
    var heartRateQuery: HKQuery?
    var previousQueryAnchor: HKQueryAnchor?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        
        //        if let watchConnectionSession = context as? WCSession {
        //            wcSession = watchConnectionSession
        //            print("Run Monitoring - WCSession established")
        //        }
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            heartRateLabel.setText("not available")
            return
        }
        startWorkout()
    }
    
    override func willActivate() {
        super.willActivate()
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            heartRateLabel.setText("not available")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            heartRateLabel.setText("not allowed")
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in
            if success == false {
                self.heartRateLabel.setText("not allowed")
            }
        }
    }
    
    //Apple Watch no longer connected to iPhone
    override func sessionReachabilityDidChange(_ session: WCSession) {
    }
    
    //Message Received from iOS
    override func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //if receive message from iPhone with UserOnRun value of FALSE - end workout & return to watch 'Start Run' controller
        if let continueRun = message["UserOnRun"] as? Bool {
            if !continueRun {
                DispatchQueue.main.async {
                    self.endWorkout()
                    WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "StartRunInterfaceController", context: self.wcSession)])
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

extension RunMonitoringInterfaceController: HKWorkoutSessionDelegate {
    //called when workout session changes - options: ended, notStarted, paused, running
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            self.createHeartRateStreamingQuery(startDate: date)
        case .ended:
            self.endWorkout()
        default:
            break
        }
    }
    
    func createHeartRateStreamingQuery(startDate: Date){
        if let query = createStreamingQuery(workoutStartDate: startDate) {
            self.heartRateQuery = query
            healthStore.execute(query)
        }
    }
    
    //code interpreted from https://developer.apple.com/documentation/healthkit/hkanchoredobjectquery
    func createStreamingQuery(workoutStartDate : Date) -> HKQuery? {
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate)
        
        let query = HKAnchoredObjectQuery(type: self.heartRateType,
                                          predicate: queryPredicate,
                                          anchor: previousQueryAnchor,
                                          limit: HKObjectQueryNoLimit)
        { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) -> Void in
            
            guard let samples = samplesOrNil else {
                // Handle the error here.
                print(errorOrNil!.localizedDescription)
                return
            }
            self.previousQueryAnchor = newAnchor
            self.getAndUpdateUserHeartRate(samples: samples)
        }
        
        //Monitors updates to the HealthKit store
        query.updateHandler = { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            
            
            guard let samples = samplesOrNil else {
                // Handle the error here.
                print(errorOrNil!.localizedDescription)
                return
            }
            self.previousQueryAnchor = newAnchor
            self.getAndUpdateUserHeartRate(samples: samples)
            
        }
        return query
    }
    
    
    func getAndUpdateUserHeartRate(samples: [HKSample]) {
        
        //if samples is of type HKQuantitySample -> Object type HealthKit uses to store user Heart Rate -> continue ... else return
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
        
        DispatchQueue.main.async {
            //if there is an entry in samples continue ... else return
            guard let firstSample = samples.first else {
                return
            }
            //get the heart rate value (as a double) for the heart rate from the populated sample
            let value = firstSample.quantity.doubleValue(for: self.heartRateUnit)
            //Update label text
            self.heartRateLabel.setText(String(Int(value)))
        }
    }
    
    func startWorkout(){
        
        let workoutConfig = HKWorkoutConfiguration()
        workoutConfig.activityType = .running
        workoutConfig.locationType = .unknown
        
        do {
            workoutSession = try HKWorkoutSession(configuration: workoutConfig)
            workoutSession?.delegate = self
            healthStore.start(workoutSession!)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func endWorkout(){
        
        if let heartRateQuery = heartRateQuery {
            healthStore.stop(heartRateQuery)
        }
        
        heartRateLabel.setText("--- bpm")
        
        if let workoutSession = workoutSession {
            healthStore.end(workoutSession)
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
}
