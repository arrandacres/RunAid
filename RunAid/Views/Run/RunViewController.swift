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
    
    //var run: Run? = Run()
    var runTimer: Timer?
    var runDuration: Int = 0
    var runDistance = Measurement(value: 0, unit: UnitLength.meters)
    var runRoute = [CLLocation]()
    let locationManager: CLLocationManager = CLLocationManager()
    var wcSession : WCSession!
    private let smsManager = EmergencyAlertSmsManager()
    
    var locationGoal: LocationGoal?
    var locationGoalAnnotation: MKPointAnnotation?
    var locationGoalCheck = false
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var runMapView: MKMapView!
    @IBOutlet weak var alertButton: ButtonProgressBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        alertButton.setProgressColor(color: .green)
        alertButton.setBackgroundColor(color: .red)
        wcSession = self.setUpWatchConnection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //set duration, ane distance to 0 - and remove any previous run route overlays from map
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
        runTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.runDuration += 1
            self.updateDisplay()
            
            if let locationGoal = self.locationGoal{
                if self.locationGoalCheck{
                    if locationGoal.time.distance(to: Double(self.runDuration)) <= 0, self.getDistance(from: (self.runRoute.last?.coordinate)!, to: locationGoal.location) < 10.0 {
                        
                        print("Goal Location not met in time")
                        
                    }
                }
            }
            
            //if watch is connected send message contain run values
            if self.wcSession.isReachable{
                self.sendAppleWatchMessage(message: self.constructRunDetailsMessage())
            }
        }
        self.beginLocationTracking()
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
    
    @IBAction func finish_run_pressed(_ sender: Any) {
        self.sendAppleWatchMessage(message:["UserOnRun": false])
        runTimer?.invalidate() //stops timer
        locationManager.stopUpdatingLocation() //stops tracking location - so map overlay doesn't update
        DispatchQueue.main.async {
            _ = self.navigationController?.popToRootViewController(animated: true) //returns to the run home view
        }
    }
    
    @IBAction func sos_alert_pressed(_ sender: Any) {
        
        self.alertButton.stopIndeterminate()
        self.alertButton.resetProgress()
        let timer = Timer.scheduledTimer(timeInterval: 0.1,
                                         target: self,
                                         selector: #selector(self.animateDeterminate),
                                         userInfo: time,
                                         repeats: true)
        RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
    }
    
    @objc func animateDeterminate(sender: Timer) {
        if self.alertButton.progress >= 1.0 {
            sender.invalidate()
        }
        else {
            self.alertButton.setProgress(progress: self.alertButton.progress + CGFloat(0.02), true)
        }
    }
    
    //Function utilised when message received from Apple Watch
    override func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("iOS Data Received: ", message)
        if let stopRun = message["StopRun"] as? Bool {
            if stopRun {
                runTimer?.invalidate() //stops timer
                locationManager.stopUpdatingLocation() //stops tracking location - so map overlay doesn't update
                DispatchQueue.main.async {
                    _ = self.navigationController?.popToRootViewController(animated: true) //returns to the run home view
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlertSegue" {
            let alertVC = segue.destination as! EmergencyContactsAlertViewController
            alertVC.alertType = .LocationGoal
            alertVC.emergencyAlertRequested = { (requested) in
                self.showComposeMessageViewController()
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
                self.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
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
        
        //for each location in updated locations list
        for location in locations {
            //if the last location stored in runRoute is not nil - assign it to variable lastLocation and continue
            if let lastLocation = runRoute.last {
                let distanceFromLastRouteLocation = location.distance(from: lastLocation) //gets the distance in metres from last location in runRoute
                //add distanceFromLastRouteLocation to runDistance
                runDistance = runDistance + Measurement(value: distanceFromLastRouteLocation, unit: UnitLength.meters)
                plotRouteUpdateOnMap(lastLocationCoOrdinates: lastLocation.coordinate, currentLocationCoOrdinates: location.coordinate)
            }
            //add new location to list of route locations
            runRoute.append(location)
        }
    }
    
    private func plotRouteUpdateOnMap(lastLocationCoOrdinates: CLLocationCoordinate2D, currentLocationCoOrdinates: CLLocationCoordinate2D) {
        //adds an overlay on the map between the last route location and the current location
        runMapView.add(MKPolyline(coordinates: [lastLocationCoOrdinates, currentLocationCoOrdinates], count: 2))
        let userCoOrdRegion = MKCoordinateRegionMakeWithDistance(currentLocationCoOrdinates, 500, 500)
        runMapView.setRegion(userCoOrdRegion, animated: true)
    }
}
