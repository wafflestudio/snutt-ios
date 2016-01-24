//
//  STLecture.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

class STLecture {
    var year : Int
    var semester : Int
    var classification : String
    var department : String
    var academicYear : String
    var courseNumber : String
    var lectureNumber : String
    var title : String
    var credit : Int
    var instructor : String
    var quota : Int
    var remark : String
    var category : String
    var id : String
    var classList :[STSingleClass] = []
    var colorIndex : Int
    
    init(json data : JSON) {
        year = data["year"].intValue
        semester = data["semester"].intValue
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
            let startTime = STTime(day: it["day"].intValue, period: it["start"].doubleValue)
            let singleClass = STSingleClass(startTime: startTime, duration: it["len"].doubleValue, place: it["place"].stringValue)
            singleClass.lecture = self
            classList.append(singleClass)
        }
    }
    
    func isEquals(right : STLecture) -> Bool {
        return (courseNumber == right.courseNumber && lectureNumber == right.lectureNumber)
    }
}