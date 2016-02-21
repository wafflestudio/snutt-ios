//
//  STCourseBook.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

struct STCourseBook {
    var quarter : STQuarter
    var update_date : String
    var start_date : String
    var end_date : String
    
    init (year aYear : Int, semester aSemester : STSemester) {
        self.quarter = STQuarter(year: aYear, semester: aSemester)
        self.update_date = ""
        self.start_date = ""
        self.end_date = ""
    }
}

extension STCourseBook : Equatable {}

func ==(lhs: STCourseBook, rhs: STCourseBook) -> Bool {
    return lhs.quarter == rhs.quarter
}