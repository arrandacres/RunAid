//
//  RunHomeViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 01/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import Foundation
import WatchConnectivity
import AWSCognitoIdentityProvider
import MapKit
import CoreLocation

class RunHomeViewController: UIViewController {
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    var wcSession : WCSession!
    let locationManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation?
    var locationGoal: LocationGoal?
    var locationCoOrds: CLLocationCoordinate2D?
    var locationGoalAnnotation: MKPointAnnotation?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let tabbar = tabBarController as! HomeViewController
        self.user = tabbar.user
        self.userAttributes = tabbar.userAttributes
        
        locationManager.requestAlwaysAuthorization()
        wcSession = self.setUpWatchConnection()
        //if location services have been enabled, get users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        wcSession.delegate = self   //set watch connection delegate
        //if location services are enabled; set user location and update map
        if CLLocationManager.locationServicesEnabled() {
            userLocation = locationManager.location
            self.showUserLocationOnMap()
        }
    }
    
    //long press gesture recogniser for map view
    //when long press detected get the lat and long of the area on the map that was pressed
    @IBAction func map_long_press(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            locationCoOrds = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            self.performSegue(withIdentifier: "showLocationGoal", sender: self)
        }
    }
    
    //before using segue to start run; send message to Apple Watch informing it to also start run
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "startRunSegue") {
            if self.wcSession.isReachable{
                wcSession.sendMessage(["UserOnRun": true], replyHandler: nil, errorHandler: { (error) in
                    print(error.localizedDescription)
                })
            }
            let runViewController = segue.destination as! RunViewController
            runViewController.locationGoal = locationGoal
            runViewController.locationGoalAnnotation = locationGoalAnnotation
        }
        
        if segue.identifier == "showLocationGoal" {
            let addLocationGoalVC = segue.destination as! AddLocationGoalViewController
            
            //saveTimeInterval callback function from AddLocationGoalViewController used to retreive selected time
            //creates new locationGoal object and sets the location and time
            addLocationGoalVC.saveTimeInterval = { (timeInterval) in
                self.locationGoal = LocationGoal()
                self.locationGoal?.location = self.locationCoOrds!
                self.locationGoal?.time = timeInterval
                self.addLocationGoalAnnotation()
            }
        }
    }
    
    func addLocationGoalAnnotation() {
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [ .hour, .minute]
        formatter.zeroFormattingBehavior = [ .pad ]
        
        //if there already is a location goal annotation remove it
        if let locationGoalAnnotation = locationGoalAnnotation{
            mapView.removeAnnotation(locationGoalAnnotation)
        }
        
        //create custom annotation and add to map view
        locationGoalAnnotation = MKPointAnnotation()
        locationGoalAnnotation?.coordinate = (locationGoal?.location)!
        locationGoalAnnotation?.title = formatter.string(from: (locationGoal?.time)!)
        mapView.addAnnotation(locationGoalAnnotation!)
    }
    
    //show user location and 1km square region
    func showUserLocationOnMap() {
        //set map region to be 1km square from the users location
        if let userlocation = userLocation?.coordinate {
        let userCoOrdRegion = MKCoordinateRegionMakeWithDistance((userLocation?.coordinate)!, 500, 500)
            mapView.showsScale = true
            //set map to show user's location region
            mapView.setRegion(userCoOrdRegion,animated: true)
        }
    }
}

//LocationManagerDelegate Code via http://www.seemuapps.com/swift-get-users-location-gps-coordinates
extension RunHomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Access Disabled",
                                                message: "We need your location.",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
