//
//  LocationGoal.swift
//  RunAid
//
//  Created by Arran Dacres on 21/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import MapKit

struct LocationGoal {

    var location: CLLocationCoordinate2D
    var time: TimeInterval
    
    init(){
        location = CLLocationCoordinate2D()
        time = 0
    }
}
