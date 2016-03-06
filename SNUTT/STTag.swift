//
//  STTag.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 4..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

enum STTagType : String {
    case Classification = "classification"
    case Department = "department"
    case AcademicYear = "academic_year"
    case Credit = "credit"
    case Instructor = "instructor"
}

struct STTag {
    var type : STTagType
    var text : String
    init(type: STTagType, text: String) {
        self.type = type
        self.text = text
    }
}