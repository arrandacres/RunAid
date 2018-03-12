//
//  Run.swift
//  RunAid
//
//  Created by Arran Dacres on 10/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation

struct Run {
    var averagePace: Double
    var distance: Measurement<Unit>?
    var durationSeconds: Int
    
    init(){
        averagePace = 0
        distance = Measurement(value:0, unit: UnitLength.miles)
        durationSeconds = 0
    }
}
