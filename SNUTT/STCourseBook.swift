//
//  STCourseBook.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

class STCourseBook {
    var year : Int
    var semester : Int
    var update_date : String
    var start_date : String
    var end_date : String
    
    var quarter : String {
        get {
            return "\(year)년 " + STTimetable.semesterToLongString[semester] + "학기"
        }
    }
    
    init (year aYear : Int, semester aSemester : Int) {
        self.year = aYear
        self.semester = aSemester
        self.update_date = ""
        self.start_date = ""
        self.end_date = ""
    }
    
}