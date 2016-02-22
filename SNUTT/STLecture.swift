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
    var quarter: STQuarter
    var classification : String = ""
    var department : String = ""
    var academicYear : String = ""
    var courseNumber : String = ""
    var lectureNumber : String = ""
    var title : String = ""
    var credit : Int = 0
    var instructor : String = ""
    var quota : Int = 0
    var remark : String = ""
    var category : String = ""
    var id : String = ""
    var classList :[STSingleClass] = []
    var colorIndex : Int = 0
    
    init(quarter: STQuarter) {
        self.quarter = quarter
    }
    
    init(json data : JSON) {
        let year = data["year"].intValue
        let semester = STSemester(rawValue: data["semester"].intValue)!
        quarter = STQuarter(year: year, semester: semester)
        classification = data["classification"].stringValue
        department = data["department"].stringValue
        academicYear = data["academic_year"].stringValue
        courseNumber = data["course_number"].stringValue
        lectureNumber = data["lecture_number"].stringValue
        title = data["course_title"].stringValue
        credit = data["credit"].intValue
        instructor = data["instructor"].stringValue
        quota = data["quota"].intValue
        remark = data["remark"].stringValue
        category = data["category"].stringValue
        id = data["_id"].stringValue
        colorIndex = data["color_index"].intValue
        let ListData = data["class_time_json"].arrayValue
        for it in ListData {
            let time = STTime(day: it["day"].intValue, startPeriod: it["start"].doubleValue, duration: it["len"].doubleValue)
            let singleClass = STSingleClass(time: time, place: it["place"].stringValue)
            classList.append(singleClass)
        }
    }
    
    func isSameLecture(right : STLecture) -> Bool {
        return (courseNumber == right.courseNumber && lectureNumber == right.lectureNumber)
    }
}

extension STLecture : Equatable {}

func ==(lhs: STLecture, rhs: STLecture) -> Bool {
    return lhs.quarter == rhs.quarter
        && lhs.classification == rhs.classification
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