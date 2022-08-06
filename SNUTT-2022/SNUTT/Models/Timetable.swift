//
//  Tiemtable.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

// MARK: Timetable

struct Timetable {
    let id: String
    var title: String
    let lectures: [Lecture]
    var theme: Theme
    let userId: String
    let year: Int
    let semester: Int
    let updatedAt: String

    /// 강의를 검색하는 동안 추가할 강의를 선택했을 때 임시로 나타나는 강의
    var selectedLecture: Lecture?

    /// 테마를 선택했을 때 임시로 사용할 테마
    var selectedTheme: Theme?

    var totalCredit: Int {
        lectures.reduce(0) { $0 + $1.credit }
    }

    var quarter: Quarter {
        Quarter(year: year, semester: .init(rawValue: semester) ?? .first)
    }

    private var aggregatedTimeMasks: [Int] {
        lectures.reduce([0, 0, 0, 0, 0, 0, 0]) { mask, lecture in
            zip(mask, lecture.timeMasks).map { $0 | $1 }
        }
    }

    /// 빈 시간대 찾기에 사용되는 마스크
    var reversedTimeMasks: [Int] {
        aggregatedTimeMasks.map { 0x3FFF_FFFF ^ $0 }
    }

    private var aggregatedTimePlaces: [TimePlace] {
        (lectures + [selectedLecture])
            .compactMap { $0 }
            .reduce(into: []) { partialResult, lecture in
                partialResult.append(contentsOf: lecture.timePlaces)
            }
    }

    var earliestStartTime: Double? {
        aggregatedTimePlaces.min(by: { $0.startTime < $1.startTime })?.startTime
    }

    var lastEndTime: Double? {
        aggregatedTimePlaces.max(by: { $0.endTime < $1.endTime })?.endTime
    }

    func withSelectedLecture(_ lecture: Lecture?) -> Self {
        var this = self
        this.selectedLecture = lecture
        return this
    }
}

extension Timetable {
    init(from dto: TimetableDto) {
        id = dto._id
        title = dto.title
        lectures = dto.lecture_list.map { .init(from: $0) }
        theme = .init(rawValue: dto.theme) ?? .snutt
        userId = dto.user_id
        year = dto.year
        semester = dto.semester
        updatedAt = dto.updated_at
    }
}

#if DEBUG
    extension Timetable {
        static var preview: Timetable {
            return .init(
                id: UUID().uuidString,
                title: "나의 시간표",
                lectures: [.preview, .preview, .preview],
                theme: .snutt,
                userId: "1234",
                year: 2022,
                semester: 1,
                updatedAt: "2022-04-02T16:35:53.652Z"
            )
        }
    }
#endif

// MARK: TimetableMetadata

struct TimetableMetadata: Codable {
    let id: String
    let year: Int
    let semester: Int
    let title: String
    let updatedAt: String
    let totalCredit: Int

    var quarter: Quarter {
        Quarter(year: year, semester: .init(rawValue: semester) ?? .first)
    }
}

extension TimetableMetadata {
    init(from dto: TimetableMetadataDto) {
        id = dto._id
        year = dto.year
        semester = dto.semester
        title = dto.title
        updatedAt = dto.updated_at
        totalCredit = dto.total_credit
    }
}
