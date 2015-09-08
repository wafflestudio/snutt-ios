//
//  STLecture.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

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
        colorIndex = Int(arc4random_uniform(UInt32(STCourseCellCollectionViewCell.backgroundColorList.count)))
        super.init()
        for it in classList {
            it.lecture = self
        }
    }
    
    func isEquals(right : STLecture) -> Bool {
        return (course_number == right.course_number && lecture_number == right.lecture_number)
    }
}