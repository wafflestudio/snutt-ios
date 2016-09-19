//
//  STLecture.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

struct STLecture {
    var classification : String?
    var department : String?
    var academicYear : String?
    var courseNumber : String?
    var lectureNumber : String?
    var title : String = ""
    var credit : Int = 0
    var instructor : String = ""
    var quota : Int?
    var remark : String?
    var category : String?
    var id : String?
    var classList :[STSingleClass] = []
    var color : STColor = STColor()
    
    init() {
    }
    
    init(json data : JSON) {
        classification = data["classification"].string
        department = data["department"].string
        academicYear = data["academic_year"].string
        courseNumber = data["course_number"].string
        lectureNumber = data["lecture_number"].string
        title = data["course_title"].stringValue
        credit = data["credit"].intValue
        instructor = data["instructor"].stringValue
        quota = data["quota"].int
        remark = data["remark"].string
        category = data["category"].string
        id = data["_id"].string
        let colorJson = data["color"]
        if let fgHex = colorJson["fg"].string, bgHex = colorJson["bg"].string {
            color = STColor(fgHex: fgHex, bgHex: bgHex)
        }
        let listData = data["class_time_json"].arrayValue
        for it in listData {
            let time = STTime(day: it["day"].intValue, startPeriod: it["start"].doubleValue, duration: it["len"].doubleValue)
            let singleClass = STSingleClass(time: time, place: it["place"].stringValue)
            classList.append(singleClass)
        }
    }
    
    func toDictionary() -> [String : AnyObject] {
        
        let classTimeJSON = classList.map{ singleClass in
            return singleClass.toDictionary()
        }
        
        var dict : [String: AnyObject?] = [
            "classification" : classification,
            "department" : department,
            "academic_year" : academicYear,
            "course_number" : courseNumber,
            "lecture_number" : lectureNumber,
            "course_title" : title,
            "credit" : credit,
            "instructor" : instructor,
            "quota" : quota,
            "remark" : remark,
            "category" : category,
            "id" : id,
            "class_time_json" : classTimeJSON,
            "color" : [ "fg" : color.fgColor.hexValue(), "bg": color.bgColor.hexValue()]
            ]
        
        for (key, value) in dict {
            if (value == nil) {
                dict.removeValueForKey(key)
            }
        }
        
        return dict as! [String: AnyObject]
    }
    
    func isSameLecture(right : STLecture) -> Bool {
        return (courseNumber == right.courseNumber && lectureNumber == right.lectureNumber)
    }
    
}

extension STLecture : Equatable {}

func ==(lhs: STLecture, rhs: STLecture) -> Bool {
    return lhs.classification == rhs.classification
        && lhs.department == rhs.department
        && lhs.academicYear == rhs.academicYear
        && lhs.courseNumber == rhs.courseNumber
        && lhs.lectureNumber == rhs.lectureNumber
        && lhs.title == rhs.title
        && lhs.credit == rhs.credit
        && lhs.instructor == rhs.instructor
        && lhs.quota == rhs.quota
        && lhs.remark == rhs.remark
        && lhs.category == rhs.category
        && lhs.id == rhs.id
        && lhs.classList == rhs.classList
}
