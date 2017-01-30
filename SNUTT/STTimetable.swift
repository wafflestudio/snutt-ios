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
    
    var lectureList : [STLecture] = []
    var quarter : STQuarter
    var title : String
    var id : String? = ""
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
        let lectures = json["lecture_list"].arrayValue
        lectures.forEach {data in
            self.addLecture(STLecture(json: data))
        }
    }
    
    func toDictionary() -> [String: AnyObject] {
        return [
            "year" : quarter.year,
            "semester" : quarter.semester.rawValue,
            "title" : title,
            "_id" : id!,
            "lecture_list" : lectureList.map({ lecture in
                return lecture.toDictionary()
            })
        ]
    }
    
    func addLecture(lecture : STLecture) -> STAddLectureState {
        for it in lectureList {
            if it.isSameLecture(lecture){
                return STAddLectureState.ErrorSameLecture
            }
            for class1 in it.classList {
                for class2 in lecture.classList {
                    if class1.time.isOverlappingWith(class2.time) {
                        return STAddLectureState.ErrorTime
                    }
                }
            }
        }
        lectureList.append(lecture)
        return STAddLectureState.Success
    }
    
    func addIdForLecture(lecture: STLecture, id : String) {
        for (index, element) in lectureList.enumerate() {
            if element == lecture {
                lectureList[index].id = id
                break
            }
        }
    }
    
    func deleteLectureAtIndex(index: Int) {
        lectureList.removeAtIndex(index)
    }
    func deleteLecture(lecture: STLecture) {
        if let index = lectureList.indexOf(lecture) {
            lectureList.removeAtIndex(index)
        }
    }
    func updateLectureAtIndex(index: Int, lecture :STLecture) {
        lectureList[index] = lecture
    }
}

extension STTimetable : Equatable {}

func ==(lhs: STTimetable, rhs: STTimetable) -> Bool {
    return lhs.quarter == rhs.quarter && lhs.title == rhs.title && lhs.id == rhs.id
}
