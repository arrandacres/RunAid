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
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup watch connection (if available)
        wcSession = self.setUpWatchConnection()
        locationManager.requestAlwaysAuthorization()
        
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
        
        userLocation = locationManager.location
        self.showUserLocationOnMap()
        
    }
    
    //show user location and 1km square region
    func showUserLocationOnMap() {
        //set map region to be 1km square from the users location
        let userCoOrdRegion = MKCoordinateRegionMakeWithDistance((userLocation?.coordinate)!, 1000, 1000)
        mapView.showsScale = true
        //set map to show user's location region
        mapView.setRegion(userCoOrdRegion,animated: true)
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
