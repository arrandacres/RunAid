//
//  RunViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 10/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
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
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var runMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        wcSession = self.setUpWatchConnection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        runDuration = 0
        runDistance = Measurement(value: 0, unit: UnitLength.meters)
        runRoute.removeAll()
        
        updateDisplay()
        runTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.runDuration += 1
            self.updateDisplay()
            
            if self.wcSession.isReachable{
                self.sendAppleWatchMessage(message: self.constructRunDetailsMessage())
            }
        }
        self.beginLocationTracking()
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
    
    //send message to Apple Watch using given message
    func sendAppleWatchMessage(message: [String: Any]) {
        wcSession.sendMessage(message, replyHandler: nil)
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
    
    @IBAction func finish_run_pressed(_ sender: Any) {
        self.sendAppleWatchMessage(message:["UserOnRun": false])
        runTimer?.invalidate() //stops timer
        locationManager.stopUpdatingLocation() //stops tracking location - so map overlay doesn't update
        DispatchQueue.main.async {
            _ = self.navigationController?.popToRootViewController(animated: true) //returns to the run home view
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

//code interpreted from https://www.raywenderlich.com/166182/mapkit-tutorial-overlay-views
extension RunViewController: MKMapViewDelegate {
    
    func mapView(_ runMapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = .orange
            lineView.lineWidth = 5
            return lineView
        }else{
            return MKOverlayRenderer(overlay:overlay)
        }
    }
}
