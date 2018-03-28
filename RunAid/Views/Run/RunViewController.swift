//
//  RunViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 10/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import ButtonProgressBar_iOS
import CoreLocation
import MapKit
import WatchConnectivity

class RunViewController: UIViewController {
    
    var runTimer: Timer?
    var runDuration: Int = 0
    var runDistance = Measurement(value: 0, unit: UnitLength.meters)
    var runRoute = [CLLocation]()
    let locationManager: CLLocationManager = CLLocationManager()
    var wcSession : WCSession!
    private let smsManager = EmergencyAlertSmsManager()
    
    var locationGoal: LocationGoal?
    var locationGoalAnnotation: MKPointAnnotation?
    private var locationGoalCheck = false
    private var alertButtonTimer: Timer?
    private var finishRunButtonTimer: Timer?
    private var lastKnownLocation: CLLocation?
    
    var userMovementTimer: Timer?
    var alertType: AlertType?
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var runMapView: MKMapView!
    @IBOutlet weak var alertButton: ButtonProgressBar!
    @IBOutlet weak var finishRunButton: ButtonProgressBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        alertButton.frame.size = CGSize(width:self.alertButton.frame.width, height:self.alertButton.frame.height)
        alertButton.layer.cornerRadius = (self.alertButton.frame.height / 2)
        alertButton.setBackgroundColor(color: UIColor("#D0021B"))
        alertButton.setProgressColor(color: UIColor("#E53532"))
        
        finishRunButton.frame.size = CGSize(width:self.finishRunButton.frame.width, height:self.finishRunButton.frame.height)
        finishRunButton.layer.cornerRadius = (self.finishRunButton.frame.height / 2)
        finishRunButton.setBackgroundColor(color: UIColor("#F38F19"))
        finishRunButton.setProgressColor(color: UIColor("#F6A749"))
        
        //set duration, and distance to 0 - and remove any previous run route overlays from map
        runDuration = 0
        runDistance = Measurement(value: 0, unit: UnitLength.meters)
        runRoute.removeAll()
        
        updateDisplay()
        
        if let locationGoal = locationGoal {
            if let locationGoalAnnotation = locationGoalAnnotation {
                addLocationGoalAnnotation(LocationGoal: locationGoal, LocationGoalAnnotation: locationGoalAnnotation)
                locationGoalCheck = true
            }
        }
        
        //start run timer
        runTimer = startRunTimer()
        
        self.beginLocationTracking()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        wcSession = self.setUpWatchConnection()
        
        if smsManager.isTextSuccessfullySent() {
            self.sendAppleWatchMessage(message: ["UserOnRun": false])
            _ = self.navigationController?.popToRootViewController(animated: true)
        }else {
            self.sendAppleWatchMessage(message: ["UserOnRun": true])
            self.sendAppleWatchMessage(message: ["SendingAlert":false])
        }
        
        self.alertButton.resetProgress()
        self.alertButton.setProgress(progress: 0, true)
        
        self.finishRunButton.resetProgress()
        self.finishRunButton.setProgress(progress: 0, true)
    }
        
    func startRunTimer() -> Timer {
        
        return Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.runDuration += 1
            self.updateDisplay()
            
            if let locationGoal = self.locationGoal{
                if self.locationGoalCheck{
                    self.monitorLocationGoal(locationGoal: locationGoal)
                }
            }
            
            //if watch is connected send message containing run values
            if self.wcSession.isReachable{
                self.sendAppleWatchMessage(message: self.constructRunDetailsMessage())
            }
        }
    }
    
    @IBAction func finish_run_long_press(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            finishRunButtonTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                //animate button
                self.animateButton(sender: self.finishRunButtonTimer!, button: self.finishRunButton, isSendAlert: false)
            }
        case .ended:
            self.finishRunButton.resetProgress()
            self.finishRunButton.setProgress(progress: 0, true)
            finishRunButtonTimer?.invalidate()
        default:
            break
        }
    }
    
    
    @IBAction func send_alert_long_press(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            alertButtonTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                //animate button
                self.animateButton(sender: self.alertButtonTimer!, button: self.alertButton, isSendAlert: true)
            }
        case .ended:
            self.alertButton.resetProgress()
            self.alertButton.setProgress(progress: 0, true)
            alertButtonTimer?.invalidate()
        default:
            break
        }
    }
    
    //animate given button
    @objc func animateButton(sender: Timer, button: ButtonProgressBar, isSendAlert: Bool) {
        if button.progress >= 0.24 {
            print("Complete")
            if isSendAlert {
                self.sendAppleWatchMessage(message: ["SendingAlert":true])
                sender.invalidate()
                self.showComposeMessageViewController()
            }else{
                sender.invalidate()
                self.sendAppleWatchMessage(message:["UserOnRun": false])
                runTimer?.invalidate() //stops timer
                userMovementTimer?.invalidate()
                locationManager.stopUpdatingLocation()
                DispatchQueue.main.async {
                    _ = self.navigationController?.popToRootViewController(animated: true) //returns to the run home view
                }
            }
        }
            //if the progress is not filled; update the progress on the button
        else {
            button.setProgress(progress: button.progress + CGFloat(0.02), true)
        }
    }
    
    private func monitorLocationGoal(locationGoal: LocationGoal) {
        //if the time set for the location goal has been passed & the user is not within 10 metres of the location
        let timeDifference = locationGoal.time.distance(to: Double(self.runDuration))
        let distance = self.getDistance(from: (self.runRoute.last?.coordinate)!, to: locationGoal.location)
        if  timeDifference >= 0, distance > 10.0 {
            self.locationGoalCheck = false
            self.runMapView.removeAnnotation(self.locationGoalAnnotation!)
            self.alertType = .LocationGoal
            self.performSegue(withIdentifier: "showAlertSegue", sender: self)
        }else if distance < 15.0{
            self.locationGoalCheck = false
            self.runMapView.removeAnnotation(self.locationGoalAnnotation!)
        }
    }
    
    func beginLocationTracking() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        showUserLocationOnMap()
    }
    
    //show user location and 1km square region
    func showUserLocationOnMap() {
        //set map region to be 1km square from the users location
        let userCoOrdRegion = MKCoordinateRegionMakeWithDistance((locationManager.location?.coordinate)!, 500, 500)
        //set map to show user's location region
        runMapView.setRegion(userCoOrdRegion,animated: true)
    }
    
    func updateDisplay() {
        
        //calculate pace
        let pace = Measurement(value : (runDuration != 0 ? (runDistance.value / Double(runDuration)) : 0) , unit: UnitSpeed.metersPerSecond)
        
        //update value labels
        distanceLabel.text = RunValueFormatter.formatRunDistance(distanceRan: runDistance)
        timeLabel.text = RunValueFormatter.formatRunTime(runTimeInSeconds: runDuration)
        paceLabel.text = RunValueFormatter.formatRunPace(pace: pace)
    }
    
    //builds run details message to send to Apple Watch during run
    func constructRunDetailsMessage() -> [String:Any]{
        var message = [String: Any]()
        message["RunDistance"] = distanceLabel.text
        message["RunTime"] = timeLabel.text
        return message
    }
    
    func addLocationGoalAnnotation(LocationGoal: LocationGoal, LocationGoalAnnotation: MKPointAnnotation) {
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [ .hour, .minute]
        formatter.zeroFormattingBehavior = [ .pad ]
        
        //if there already is a location goal annotation remove it
        if let locationGoalAnnotation = locationGoalAnnotation{
            runMapView.removeAnnotation(locationGoalAnnotation)
        }
        
        //create custom annotation and add to map view
        locationGoalAnnotation = MKPointAnnotation()
        locationGoalAnnotation?.coordinate = (locationGoal?.location)!
        locationGoalAnnotation?.title = formatter.string(from: (locationGoal?.time)!)
        runMapView.addAnnotation(locationGoalAnnotation!)
    }
    
    //code from https://stackoverflow.com/questions/11077425/finding-distance-between-cllocationcoordinate2d-points
    func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    
    //send message to Apple Watch using given message
    func sendAppleWatchMessage(message: [String: Any]) {
        wcSession.sendMessage(message, replyHandler: nil)
    }
    
    
    
    //Function utilised when message received from Apple Watch
    override func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("iOS Data Received: ", message)
        if let stopRun = message["StopRun"] as? Bool {
            if stopRun {
                runTimer?.invalidate() //stops timer
                userMovementTimer?.invalidate()
                locationManager.stopUpdatingLocation() //stops tracking location - so map overlay doesn't update
                DispatchQueue.main.async {
                    _ = self.navigationController?.popToRootViewController(animated: true) //returns to the run home view
                }
            }
        }
        
        if let sendSOSAlert = message["SendSOSAlert"] as? Bool {
            if sendSOSAlert {
                self.showComposeMessageViewController()
            }
        }
    }
    
    private func startUserMovementTimer() -> Timer {
        
        return Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.alertType = .NoMovement
            self.performSegue(withIdentifier: "showAlertSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showAlertSegue" {
            let alertVC = segue.destination as! EmergencyContactsAlertViewController
            alertVC.alertType = alertType!
            alertVC.wcSession = self.wcSession
            alertVC.emergencyAlertRequested = { (requested) in
                //if the alert view controller has requested an emergency alert
                if requested {
                    self.showComposeMessageViewController()
                }
            }
        }
    }
    
    private func showComposeMessageViewController() {
        //if can create a SMS Message compose VC
        if self.smsManager.deviceCanSendSMS(){
            if let messageComposeVC = self.smsManager.getMessageComposeViewController(messageRecipients: getUserEmergencyContacts(), lastKnownLocation: runRoute.last!) {
                
                self.present(messageComposeVC, animated: true)
            }
        }else{
            //if user's device cannot send text messages; show alert
            let alert = UIAlertController(title: "Cannot send SMS Message", message: "Your device cannot send text messages.", preferredStyle: .alert)
            //custom action - dismisses both alertVCs
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.sendAppleWatchMessage(message: ["SendingAlert":false])
                self.dismiss(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //gets the user's emergency contact phone number stored in UserDefaults
    private func getUserEmergencyContacts() -> [String] {
        
        var contactPhoneNumbers = [String]()
        
        if let emergencyContacts = (UserDefaults.standard.value(forKey: "EmergencyContacts") as? [[String:String]]) {
            for contact in emergencyContacts {
                if let phoneNumber = contact["phone number"] {
                    contactPhoneNumbers.append(phoneNumber)
                }
            }
        }
        return contactPhoneNumbers
    }
}

extension RunViewController: CLLocationManagerDelegate {
    
    //function hit when new location data received
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let userMovementTimer = userMovementTimer {
            userMovementTimer.invalidate()
        }
        
        //for each location in updated locations list
        for location in locations {
            //if the last location stored in runRoute is not nil - assign it to variable lastLocation and continue
            if let lastLocation = runRoute.last {
                lastKnownLocation = lastLocation
                let distanceFromLastRouteLocation = location.distance(from: lastLocation) //gets the distance in metres from last location in runRoute
                //add distanceFromLastRouteLocation to runDistance
                runDistance = runDistance + Measurement(value: distanceFromLastRouteLocation, unit: UnitLength.meters)
                plotRouteUpdateOnMap(lastLocationCoOrdinates: lastLocation.coordinate, currentLocationCoOrdinates: location.coordinate)
            }
            //add new location to list of route locations
            runRoute.append(location)
        }
        print("Start Movement Timer")
        userMovementTimer = startUserMovementTimer()
    }
    
    private func plotRouteUpdateOnMap(lastLocationCoOrdinates: CLLocationCoordinate2D, currentLocationCoOrdinates: CLLocationCoordinate2D) {
        //adds an overlay on the map between the last route location and the current location
        runMapView.add(MKPolyline(coordinates: [lastLocationCoOrdinates, currentLocationCoOrdinates], count: 2))
        let userCoOrdRegion = MKCoordinateRegionMakeWithDistance(currentLocationCoOrdinates, 500, 500)
        runMapView.setRegion(userCoOrdRegion, animated: true)
    }
}
