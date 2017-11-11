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
    var title : String = "" {
        didSet {
            titleBreakLine = title.breakOnlyAtNewLineAndSpace
        }
    }
    var credit : Int = 0
    var instructor : String = ""
    var quota : Int?
    var remark : String?
    var category : String?
    var id : String?
    var classList :[STSingleClass] = []
    var color : STColor? = nil
    var colorIndex: Int = 0
    var timeMask: [Int] = []
    var titleBreakLine = ""

    func getColor() -> STColor {
        let colorList = STColorManager.sharedInstance.colorList!
        if colorIndex == 0 {
            return color ?? STColor()
        } else if (colorIndex <= colorList.colorList.count && colorIndex >= 1) {
            return colorList.colorList[colorIndex - 1]
        } else {
            return STColor()
        }
    }

    var timeDescription : String {
        var ret: String = ""
        for it in classList {
            ret = ret + "/" + it.time.startString()
        }
        if ret != "" {
            ret = ret.substring(from: ret.characters.index(ret.startIndex, offsetBy: 1))
        } else {
            ret = "(없음)"
        }
        return ret
    }
    
    var placeDescription : String {
        var ret: String = ""
        for it in classList {
            ret = ret + "/" + it.place
        }
        if ret != "" {
            ret = ret.substring(from: ret.characters.index(ret.startIndex, offsetBy: 1))
        } else {
            ret = "(없음)"
        }
        return ret
    }
    
    var tagDescription : String {
        var ret: String = ""
        if category != nil && category != ""{
            ret = ret + ", " + category!
        }
        if department != nil && department != "" {
            ret = ret + ", " + department!
        }
        if academicYear != nil && academicYear != "" {
            ret = ret + ", " + academicYear!
        }
        if ret != "" {
            ret = ret.substring(from: ret.characters.index(ret.startIndex, offsetBy: 2))
        } else {
            ret = "(없음)"
        }
        return ret
    }
    
    init() {
    }
    
    init(json data : JSON) {
        classification = data["classification"].string
        department = data["department"].string
        academicYear = data["academic_year"].string
        courseNumber = data["course_number"].string
        lectureNumber = data["lecture_number"].string
        title = data["course_title"].stringValue
        titleBreakLine = title.breakOnlyAtNewLineAndSpace
        credit = data["credit"].intValue
        instructor = data["instructor"].stringValue
        quota = data["quota"].int
        remark = data["remark"].string
        category = data["category"].string
        timeMask = data["class_time_mask"].arrayValue.map{mask in mask.intValue}
        id = data["_id"].string
        let colorJson = data["color"]
        colorIndex = data["colorIndex"].intValue
        if let fgHex = colorJson["fg"].string, let bgHex = colorJson["bg"].string {
            color = STColor(fgHex: fgHex, bgHex: bgHex)
        }

        let listData = data["class_time_json"].arrayValue
        for it in listData {
            let time = STTime(day: it["day"].intValue, startPeriod: it["start"].doubleValue, duration: it["len"].doubleValue)
            let singleClass = STSingleClass(time: time, place: it["place"].stringValue)
            classList.append(singleClass)
        }
    }
    
    func toDictionary() -> [String : Any] {
        
        let classTimeJSON = classList.map{ singleClass in
            return singleClass.toDictionary()
        }
        
        var dict : [String: Any?] = [
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
            "color" : color?.dictionaryValue(),
            "colorIndex" : colorIndex,
            ]
        
        for (key, value) in dict {
            if (value == nil) {
                dict.removeValue(forKey: key)
            }
        }
        
        return dict as! [String: AnyObject]
    }
    
    func isSameLecture(_ right : STLecture) -> Bool {
        return (courseNumber == right.courseNumber && lectureNumber == right.lectureNumber) && courseNumber != nil && lectureNumber != nil
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
        && lhs.color == rhs.color
        && lhs.colorIndex == rhs.colorIndex
}
