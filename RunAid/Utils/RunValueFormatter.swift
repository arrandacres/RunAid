//
//  RunValueFormatter.swift
//  RunAid
//
//  Created by Arran Dacres on 11/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import Foundation

struct RunValueFormatter {
    
    static func formatRunDistance(distanceRan: Measurement<UnitLength>) -> String {
        
        //number formatter to limit string output to 2 decimal places and ensure always at least one value in front of decimal place
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.numberFormatter = numberFormatter
        measurementFormatter.unitStyle = MeasurementFormatter.UnitStyle.medium
        return measurementFormatter.string(from: distanceRan)
    }
    
    //time formatter code interpreted from https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
    static func formatRunTime(runTimeInSeconds: Int) -> String {
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
        dateComponentsFormatter.unitsStyle = .positional
        dateComponentsFormatter.zeroFormattingBehavior = .pad //required so that it includes 0's
        
        return dateComponentsFormatter.string(from: TimeInterval(runTimeInSeconds))!
    }
    
    //formats user pace
    static func formatRunPace(pace: Measurement<UnitSpeed>) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.numberFormatter = numberFormatter
        measurementFormatter.unitOptions = .providedUnit
        
        return measurementFormatter.string(from: pace.converted(to: .milesPerHour))
    }
    
}
