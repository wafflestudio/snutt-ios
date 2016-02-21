//
//  STTimetable.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

enum STAddLectureState {
    case Success, ErrorTime, ErrorSameLecture
}

class STTimetable {
    
    private(set) var lectureList : [STLecture] = []
    private(set) var quarter : STQuarter
    private(set) var title : String
    private(set) var id : String? 
    var temporaryLecture : STLecture? = nil
    
    var isLoaded : Bool {
        get {
            return !(id==nil)
        }
    }
    
    init(year aYear: Int, semester aSemester: STSemester, title aTitle: String) {
        self.quarter = STQuarter(year: aYear, semester: aSemester)
        self.title = aTitle
    }
    
    init(courseBook : STCourseBook, title: String) {
        self.quarter = courseBook.quarter
        self.title = title
    }
    
    init(json : JSON) {
        let year = json["year"].intValue
        let semester = STSemester(rawValue: json["semester"].intValue)!
        self.quarter = STQuarter(year: year, semester: semester)
        self.title = json["title"].stringValue
        self.id = json["_id"].string
        let lectures = json["lectures"].arrayValue
        lectures.forEach {data in
            self.addLecture(STLecture(json: data))
        }
    }
    
    func addLecture(lecture : STLecture) -> STAddLectureState {
        for it in lectureList {
            if it.isSameLecture(lecture){
                return STAddLectureState.ErrorSameLecture
            }
        }
        lectureList.append(lecture)
        return STAddLectureState.Success
    }
    func deleteLectureAtIndex(index: Int) {
        lectureList.removeAtIndex(index)
    }
}

extension STTimetable : Equatable {}

func ==(lhs: STTimetable, rhs: STTimetable) -> Bool {
    return lhs.quarter == rhs.quarter && lhs.title == rhs.title && lhs.id == rhs.id
}
