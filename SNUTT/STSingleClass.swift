//
//  STSingleClass.swift
//  SNUTT
//
//  Created by Rajin on 2015. 9. 6..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

class STSingleClass : NSObject, NSCoding{
    var startTime : STTime
    var duration : Int
    var place : String
    weak var lecture : STLecture?
    var timeString : String? {
        get {
            var finishTime = STTime(day: startTime.day, period: startTime.period + duration*2)
            return "\(startTime.toString())~\(finishTime.periodToString())"
        }
    }
    init(startTime tTime : STTime, duration tDuration : Int, place tPlace:String) {
        startTime = tTime
        duration = tDuration
        place = tPlace
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        startTime = aDecoder.decodeObjectForKey("startTime") as! STTime
        duration = aDecoder.decodeObjectForKey("duration") as! Int
        place = aDecoder.decodeObjectForKey("place") as! String
        super.init()
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(startTime, forKey: "startTime")
        aCoder.encodeObject(duration, forKey: "duration")
        aCoder.encodeObject(place, forKey: "place")
        
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