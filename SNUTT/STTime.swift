//
//  STTime.swift
//  SNUTT
//
//  Created by Rajin on 2015. 9. 6..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

class STTime {
    enum STDay : Int{
        case MON=0, TUE, WED, THU, FRI, SAT
    }
    var day : STDay
    var period : Double
    static var periodNum : Int = 14
    static var dayToString = ["월", "화", "수", "목", "금", "토"]
    static var stringToDay = ["월" : STDay.MON, "화" : STDay.TUE, "수" : STDay.WED, "목" : STDay.THU, "금" : STDay.FRI, "토" : STDay.SAT]
    
    init(day tDay: Int, period tPeriod: Double) {
        day = STDay(rawValue: tDay)!
        period = tPeriod
    }
    
    func periodToString() -> String {
        if Int(period * 2.0) % 2 == 0 {
            return "\(Int(period)+8):00"
        } else {
            return "\(Int(period)+8):30"
        }
    }
    func toString() -> String {
        let dayString = STTime.dayToString[day.rawValue]
        let periodString = periodToString()
        return "\(dayString) \(periodString)"
    }
    func toShortString() -> String {
        return "\(STTime.dayToString[day.rawValue])\(period)"
    }
}
