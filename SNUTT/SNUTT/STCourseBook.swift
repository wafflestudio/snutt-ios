//
//  STCourseBook.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

struct STCourseBook : DictionaryRepresentable{
    var quarter : STQuarter
    
    init (year aYear : Int, semester aSemester : STSemester) {
        self.quarter = STQuarter(year: aYear, semester: aSemester)
    }
    
    init (json: JSON) {
        let year = json["year"].intValue
        let semester = STSemester(rawValue: json["semester"].intValue)!
        self.init(year: year, semester: semester)
    }
    
    //MARK: DictionaryRepresentable
    
    func dictionaryValue() -> NSDictionary {
        return self.quarter.dictionaryValue()
    }
    init?(dictionary: NSDictionary?) {
        guard let quarter = STQuarter(dictionary: dictionary) else { return nil }
        self.quarter = quarter
    }

}

extension STCourseBook : Equatable {}

func ==(lhs: STCourseBook, rhs: STCourseBook) -> Bool {
    return lhs.quarter == rhs.quarter
}