//
//  Lecture.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

class STTime : NSObject, NSCoding{
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
    required init(coder aDecoder: NSCoder) {
        day = STDay(rawValue: aDecoder.decodeObjectForKey("day") as! Int)!
        period = aDecoder.decodeObjectForKey("period") as! Int
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(day.rawValue, forKey: "day")
        aCoder.encodeObject(period, forKey: "period")
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

class STLecture : NSObject , NSCoding{
    var name : String
    var professor : String
    var credit : Int
    var classification : String
    var department : String
    var classList :[STSingleClass] = []
    var course_number : String
    var lecture_number : String
    var colorIndex : Int
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        professor = aDecoder.decodeObjectForKey("professor") as! String
        credit = aDecoder.decodeObjectForKey("credit") as! Int
        classification = aDecoder.decodeObjectForKey("classification") as! String
        department = aDecoder.decodeObjectForKey("department") as! String
        classList = aDecoder.decodeObjectForKey("classList") as! [STSingleClass]
        course_number = aDecoder.decodeObjectForKey("course_number") as! String
        lecture_number = aDecoder.decodeObjectForKey("lecture_number") as! String
        colorIndex = aDecoder.decodeObjectForKey("colorIndex") as! Int
        super.init()
        for singleClass in classList {
            singleClass.lecture = self
        }
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(professor, forKey: "professor")
        aCoder.encodeObject(credit, forKey: "credit")
        aCoder.encodeObject(classification, forKey: "classification")
        aCoder.encodeObject(department, forKey: "department")
        aCoder.encodeObject(classList, forKey: "classList")
        aCoder.encodeObject(course_number, forKey: "course_number")
        aCoder.encodeObject(lecture_number, forKey: "lecture_number")
        aCoder.encodeObject(colorIndex, forKey: "colorIndex")

    }
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
        super.init()
        for it in classList {
            it.lecture = self
        }
    }
    
    func isEquals(right : STLecture) -> Bool {
        return (course_number == right.course_number && lecture_number == right.lecture_number)
    }
}