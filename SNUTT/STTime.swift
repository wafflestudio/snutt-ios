//
//  STTime.swift
//  SNUTT
//
//  Created by Rajin on 2015. 9. 6..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

class STTime : NSObject, NSCoding{
    enum STDay : Int{
        case MON=0, TUE, WED, THU, FRI, SAT
    }
    var day : STDay
    var period : Int
    static var periodNum : Int = 28
    static var dayToString = ["월", "화", "수", "목", "금", "토"]
    static var stringToDay = ["월" : STDay.MON, "화" : STDay.TUE, "수" : STDay.WED, "목" : STDay.THU, "금" : STDay.FRI, "토" : STDay.SAT]
    init(day tDay:STDay, period tPeriod:Int) {
        day = tDay
        period = tPeriod
    }
    init(day tDay:String, period tPeriod: Double) {
        day = STTime.stringToDay[tDay]!
        period = (Int)(tPeriod * 2)
    }
    required init?(coder aDecoder: NSCoder) {
        day = STDay(rawValue: aDecoder.decodeObjectForKey("day") as! Int)!
        period = aDecoder.decodeObjectForKey("period") as! Int
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(day.rawValue, forKey: "day")
        aCoder.encodeObject(period, forKey: "period")
    }
    func periodToString() -> String {
        if period % 2 == 0 {
            return "\(period/2+8):00"
        } else {
            return "\(period/2+8):30"
        }
    }
    func toString() -> String {
        let dayString = STTime.dayToString[day.rawValue]
        let periodString = periodToString()
        return "\(dayString) \(periodString)"
    }
    func toShortString() -> String {
        return "\(STTime.dayToString[day.rawValue])\(Double(period)/2.0)"
    }
}
