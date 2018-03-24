//
//  UIViewControllerMapAnnotationDelegateExtension.swift
//  RunAid
//
//  Created by Arran Dacres on 22/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import MapKit

//code interpreted from https://www.raywenderlich.com/166182/mapkit-tutorial-overlay-views
extension UIViewController: MKMapViewDelegate {
    
    public func mapView(_ runMapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = .orange
            lineView.lineWidth = 5
            return lineView
        }else{
            return MKOverlayRenderer(overlay:overlay)
        }
    }
    
    //delegate method used for adding annotation to map
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let goalLocationAnnotationIdentifier = "GoalLocationAnnotationIdentifier"
        var goalLocationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: goalLocationAnnotationIdentifier)
        
        if goalLocationAnnotationView == nil {
            goalLocationAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: goalLocationAnnotationIdentifier)
            goalLocationAnnotationView!.canShowCallout = true
        }
        else {
            goalLocationAnnotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "GoalLocationPin2")
        goalLocationAnnotationView!.image = pinImage
        goalLocationAnnotationView?.transform = CGAffineTransform(scaleX: 0.1, y:0.1)
        return goalLocationAnnotationView
    }
}
