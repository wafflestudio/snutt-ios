//
//  PreviewHelpers.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct PreviewTimetable: Timetable {
    public let id: String = UUID().uuidString
    public let title: String
    public let quarter: Quarter
    public let lectures: [any Lecture]
    public let userID: String

    public func encode(to encoder: any Encoder) throws {}
    public init(from decoder: any Decoder) throws { fatalError() }

    public static var preview: any Timetable {
        let previewLectures: [any Lecture] = [
            PreviewLecture(
                id: UUID().uuidString,
                lectureID: "CS101",
                courseTitle: "Introduction to Computer Science",
                timePlaces: [
                    TimePlace(
                        id: UUID().uuidString,
                        day: .mon,
                        startTime: Time(hour: 9, minute: 0),
                        endTime: Time(hour: 10, minute: 30),
                        place: "Room 101"
                    ),
                    TimePlace(
                        id: UUID().uuidString,
                        day: .wed,
                        startTime: Time(hour: 9, minute: 0),
                        endTime: Time(hour: 10, minute: 30),
                        place: "Room 101"
                    )
                ],
                lectureNumber: "001",
                instructor: "Prof. Smith",
                credit: 3,
                department: "Computer Science",
                academicYear: "Freshman"
            ),
            PreviewLecture(
                id: UUID().uuidString,
                lectureID: "MATH201",
                courseTitle: "Calculus II",
                timePlaces: [
                    TimePlace(
                        id: UUID().uuidString,
                        day: .tue,
                        startTime: Time(hour: 11, minute: 0),
                        endTime: Time(hour: 12, minute: 30),
                        place: "Room 202"
                    ),
                    TimePlace(
                        id: UUID().uuidString,
                        day: .thu,
                        startTime: Time(hour: 11, minute: 0),
                        endTime: Time(hour: 12, minute: 30),
                        place: "Room 202"
                    )
                ],
                lectureNumber: "002",
                instructor: "Dr. Johnson",
                credit: 4,
                department: "Physics",
                academicYear: "Freshman",
                evLecture: .init(evLectureID: 1, avgRating: 4.8, evaluationCount: 20)
            ),
            PreviewLecture(
                id: UUID().uuidString,
                lectureID: "PHYS101",
                courseTitle: "Physics I",
                timePlaces: [
                    TimePlace(
                        id: UUID().uuidString,
                        day: .fri,
                        startTime: Time(hour: 14, minute: 0),
                        endTime: Time(hour: 15, minute: 30),
                        place: "Room 303"
                    )
                ],
                lectureNumber: "003",
                instructor: "Prof. Lee",
                credit: 3,
                department: "Physics",
                academicYear: "Freshman",
                evLecture: .init(evLectureID: 2, avgRating: 3.2, evaluationCount: 20),
                remark: "Korean only."
            ),
            PreviewLecture(
                id: UUID().uuidString,
                lectureID: "PHYS102",
                courseTitle: "고급항공전자 (복합항법시스템(Integrated Navigation System))",
                timePlaces: [
                    TimePlace(
                        id: UUID().uuidString,
                        day: .fri,
                        startTime: Time(hour: 14, minute: 0),
                        endTime: Time(hour: 15, minute: 30),
                        place: "Room 303"
                    )
                ],
                lectureNumber: "003",
                instructor: "박찬국",
                credit: 3,
                department: "Physics",
                academicYear: "Freshman",
                evLecture: .init(evLectureID: 2, avgRating: 3.2, evaluationCount: 20),
                remark: "Korean only."
            )
        ]

        return PreviewTimetable(
            title: "Fall 2023 Timetable",
            quarter: Quarter(year: 2023, semester: .second),
            lectures: previewLectures,
            userID: "user123"
        )
    }
}

private struct PreviewLecture: Lecture, Codable {
    var id: String
    var lectureID: String?
    var courseTitle: String
    var timePlaces: [TimePlace]
    var lectureNumber: String?
    var instructor: String?
    var credit: Int64?
    var courseNumber: String?
    var department: String?
    var academicYear: String?
    var evLecture: EvLecture?
    var remark: String? = nil
}


