//
//  Lecture.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

class STTime {
    enum STDay : Int{
        case MON=0, TUE, WED, THU, FRI, SAT
    }
    var day : STDay
    var period : Int
    static var periodNum : Int = 13
    static var dayToString = ["월", "화", "수", "목", "금", "토"]
    init(day tDay:STDay, period tPeriod:Int) {
        day = tDay
        period = tPeriod
    }
    func periodToString() -> String {
        if period % 2 == 0 {
            return "\(period/2+9):00"
        } else {
            return "\(period/2+9):30"
        }
    }
    func toString() -> String {
        var dayString = STTime.dayToString[day.rawValue]
        var periodString = periodToString()
        return "\(dayString) \(periodString)"
    }
}

class STSingleClass {
    var startTime : STTime
    var duration : Int
    var place : String
    var lecture : STLecture?
    init(startTime tTime : STTime, duration tDuration : Int, place tPlace:String) {
        startTime = tTime
        duration = tDuration
        place = tPlace
    }
}

class STLecture {
    var name : String
    var professor : String
    var classList :[STSingleClass]
    init(name tName : String, professor tProfessor: String, classList tClassList : [STSingleClass]) {
        name  = tName
        professor = tProfessor
        classList = tClassList
        for it in classList {
            it.lecture = self
        }
    }
}