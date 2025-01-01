//
//  LectureEditDetailViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Observation
import TimetableInterface

@MainActor
@Observable
final class LectureEditDetailViewModel {
    let entryLecture: EditableLecture
    var editableLecture: EditableLecture

    init(entryLecture: any Lecture) {
        self.entryLecture = Self.makeEditableLecture(from: entryLecture)
        self.editableLecture = Self.makeEditableLecture(from: entryLecture)
    }

    private static func makeEditableLecture(from entryLecture: any Lecture) -> EditableLecture {
        .init(
            id: entryLecture.id,
            lectureID: entryLecture.lectureID,
            courseTitle: entryLecture.courseTitle,
            timePlaces: entryLecture.timePlaces,
            lectureNumber: entryLecture.lectureNumber,
            instructor: entryLecture.instructor,
            credit: entryLecture.credit,
            courseNumber: entryLecture.courseNumber,
            department: entryLecture.department,
            academicYear: entryLecture.academicYear,
            remark: entryLecture.remark,
            evLecture: entryLecture.evLecture,
            customColor: entryLecture.customColor,
            classification: entryLecture.classification,
            category: entryLecture.category,
            quota: entryLecture.quota,
            freshmenQuota: entryLecture.freshmenQuota
        )
    }
}

struct EditableLecture: Lecture {
    
    var id: String
    var lectureID: String?
    var courseTitle: String
    var timePlaces: [TimetableInterface.TimePlace]
    var lectureNumber: String?
    var instructor: String?
    var credit: Int64?
    var courseNumber: String?
    var department: String?
    var academicYear: String?
    var remark: String?
    var evLecture: TimetableInterface.EvLecture?
    var customColor: TimetableInterface.LectureColor?
    var classification: String?
    var category: String?

    var quota: Int32?
    var freshmenQuota: Int32?

    var quotaDescription: String? {
        get {
            if let quota, let freshmenQuota {
                return "\(quota)(\(freshmenQuota))"
            }
            return nil
        }
        set { }
    }
}
