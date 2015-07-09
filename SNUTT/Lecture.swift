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
    static var stringToDay = ["월" : STDay.MON, "화" : STDay.TUE, "수" : STDay.WED, "목" : STDay.THU, "금" : STDay.FRI, "토" : STDay.SAT]
    init(day tDay:STDay, period tPeriod:Int) {
        day = tDay
        period = tPeriod
    }
    init(day tDay:String, period tPeriod: Double) {
        day = STTime.stringToDay[tDay]!
        period = (Int)(tPeriod * 2)
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
    func toShortString() -> String {
        return "\(STTime.dayToString[day.rawValue])\(Double(period)/2.0)"
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

class STLecture {
    var name : String
    var professor : String
    var credit : Int
    var classification : String
    var department : String
    var classList :[STSingleClass] = []
    var course_number : String
    var lecture_number : String
    var colorIndex : Int
    init(json data : NSDictionary) {
        var timeData = data["class_time"] as! String
        var timeArr = split(timeData){$0 == "/"}
        var locationData = data["location"] as! String
        var locationArr = split(locationData){$0 == "/"}
        if locationArr.count == 0{
            locationArr = ["","","","",""]
        }
        for i in 0..<timeArr.count {
            var time = timeArr[i]
            var t = split(time) {
                (params) -> Bool in
                var ret = (params == ")")
                ret = ret || (params == "(") || (params == "-")
                return ret
            }
            classList.append(STSingleClass(startTime : STTime(day : t[0], period : (t[1] as NSString).doubleValue), duration : (Int)((t[2] as NSString).doubleValue * 2.0), place : locationArr[i]))
        }
        name = data["course_title"] as! String
        professor = data["instructor"] as! String
        credit = (data["credit"] as! NSString).integerValue
        classification = data["classification"] as! String
        department = data["department"] as! String
        course_number = data["course_number"] as! String
        lecture_number = data["lecture_number"] as! String
        colorIndex = Int(arc4random_uniform(UInt32(CourseCellCollectionViewCell.backgroundColorList.count)))

        for it in classList {
            it.lecture = self
        }
    }
    
    func isEquals(right : STLecture) -> Bool {
        return (course_number == right.course_number && lecture_number == right.lecture_number)
    }
}