//
//  STTimetable.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

class STTimetable {
    var lectureList: [STLecture] = []
    var quarter: STQuarter
    var title: String
    var id: String? = ""
    var temporaryLecture: STLecture?
    var theme: STTheme?
    var totalCredit: Int?

    var isLoaded: Bool {
        return !(id == nil)
    }

    var totalCreditByCal: Int {
        var credit = 0
        for lecture in lectureList {
            credit += lecture.credit
        }
        return credit
    }

    init(year aYear: Int, semester aSemester: STSemester, title aTitle: String) {
        quarter = STQuarter(year: aYear, semester: aSemester)
        title = aTitle
    }

    init(courseBook: STCourseBook, title: String) {
        quarter = courseBook.quarter
        self.title = title
    }

    init(json: JSON) {
        let year = json["year"].intValue
        let semester = STSemester(rawValue: json["semester"].intValue)!
        quarter = STQuarter(year: year, semester: semester)
        title = json["title"].stringValue
        id = json["_id"].string
        theme = STTheme(rawValue: json["theme"].intValue)
        totalCredit = json["total_credit"].intValue
        let lectures = json["lecture_list"].arrayValue
        lectures.forEach { data in
            self.addLecture(STLecture(json: data))
        }
    }

    func toDictionary() -> [String: Any] {
        return [
            "year": quarter.year,
            "semester": quarter.semester.rawValue,
            "title": title,
            "_id": id!,
            "lecture_list": lectureList.map { lecture in
                lecture.toDictionary()
            },
            "theme": theme?.rawValue ?? 1,
        ]
    }

    func addLecture(_ lecture: STLecture) {
        for it in lectureList {
            if it.isSameLecture(lecture) {
                return
            }
            for class1 in it.classList {
                for class2 in lecture.classList {
                    if class1.time.isOverlappingWith(class2.time) {
                        return
                    }
                }
            }
        }
        lectureList.append(lecture)
    }

    func indexOf(lecture: STLecture) -> Int {
        for (index, it) in lectureList.enumerated() {
            if it.isSameLecture(lecture) {
                return index
            }
        }
        return -1
    }

    func deleteLectureAtIndex(_ index: Int) {
        lectureList.remove(at: index)
    }

    func deleteLecture(_ lecture: STLecture) {
        if let index = lectureList.index(of: lecture) {
            lectureList.remove(at: index)
        }
    }

    func updateLectureAtIndex(_ index: Int, lecture: STLecture) {
        lectureList[index] = lecture
    }

    func timetableTimeMask() -> [Int] {
        return lectureList.reduce([0, 0, 0, 0, 0, 0, 0]) { mask, lecture in
            zip(mask, lecture.timeMask).map { t1, t2 in t1 | t2 }
        }
    }

    func timetableReverseTimeMask() -> [Int] {
        return timetableTimeMask().map { t1 in 0x3FFF_FFFF ^ t1 }
    }
}

extension STTimetable: Equatable {}

func == (lhs: STTimetable, rhs: STTimetable) -> Bool {
    return lhs.quarter == rhs.quarter && lhs.title == rhs.title && lhs.id == rhs.id
}
