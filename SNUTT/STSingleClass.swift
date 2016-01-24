//
//  STSingleClass.swift
//  SNUTT
//
//  Created by Rajin on 2015. 9. 6..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

class STSingleClass {
    var startTime : STTime
    var duration : Double
    var place : String
    weak var lecture : STLecture?
    
    var timeString : String? {
        get {
            let finishTime = STTime(day: startTime.day.rawValue, period: Double(startTime.period) + duration*2)
            return "\(startTime.toString())~\(finishTime.periodToString())"
        }
    }
    
    init(startTime tTime : STTime, duration tDuration : Double, place tPlace:String) {
        startTime = tTime
        duration = tDuration
        place = tPlace
    }
    
    func isOverlappingWith(tmp : STSingleClass) -> Bool {
        if startTime.day != tmp.startTime.day {
            return false
        }
        if tmp.startTime.period < startTime.period {
            if (tmp.startTime.period + tmp.duration > startTime.period) {
                return true
            }
            return false
        } else {
            if (startTime.period + duration > tmp.startTime.period) {
                return true
            }
            return false
        }
    }
}