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
        wcSession.delegate = self
        if CLLocationManager.locationServicesEnabled() {
        userLocation = locationManager.location
        self.showUserLocationOnMap()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "startRunSegue") {
            print("Start Run Button Pressed")
            wcSession.sendMessage(["UserOnRun": true], replyHandler: nil, errorHandler: { (error) in
                print(error.localizedDescription)
            })
        }
    }
    
    //show user location and 1km square region
    func showUserLocationOnMap() {
        //set map region to be 1km square from the users location
        let userCoOrdRegion = MKCoordinateRegionMakeWithDistance((userLocation?.coordinate)!, 500, 500)
        mapView.showsScale = true
        //set map to show user's location region
        mapView.setRegion(userCoOrdRegion,animated: true)
    }
    
//    override func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        if let beginRun = message["BeginRun"] as? Bool {
//            if beginRun {
//                //Go to Run View Controller
//                DispatchQueue.main.async {
//                    if let runViewController  = self.storyboard?.instantiateViewController(withIdentifier: "RunDetailsVC") as? RunViewController {
//                        self.present(runViewController, animated: true, completion: nil)
//                    }
//                }
//            }
//        }
//    }
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
