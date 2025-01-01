//
//  PreviewHelpers.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import GameKit
import MemberwiseInit

public enum PreviewHelpers {
    public static var preview: any Timetable {
        preview(with: "1")
    }

    public static func preview(with id: String) -> any Timetable {
        let seed = {
            var hasher = Hasher()
            hasher.combine(id)
            return hasher.finalize()
        }()
        var generator = DeterministicRandomNumberGenerator(seed: seed)
        return PreviewTimetable(
            id: id,
            title: timetableTitles.randomElement(using: &generator)!,
            quarter: quarters.randomElement(using: &generator)!,
            lectures: (3 ... Int.random(in: 4 ... 6, using: &generator)).map { _ in previewLecture(using: &generator) },
            userID: "user123"
        )
    }

    public static func previewMetadata(with id: String) -> any TimetableMetadata {
        let seed = {
            var hasher = Hasher()
            hasher.combine(id)
            return hasher.finalize()
        }()
        var generator = DeterministicRandomNumberGenerator(seed: seed)
        return PreviewTimetableMetadata(
            id: id,
            title: timetableTitles.randomElement(using: &generator)!,
            quarter: quarters.randomElement(using: &generator)!,
            totalCredit: Int.random(in: 6 ... 18, using: &generator),
            isPrimary: Bool.random(using: &generator)
        )
    }

    private static func previewLecture<T: RandomNumberGenerator>(using generator: inout T) -> PreviewLecture {
        PreviewLecture(
            id: UUID().uuidString,
            lectureID: UUID().uuidString,
            courseTitle: courseTitles.randomElement(using: &generator)!,
            timePlaces: (1 ... Int.random(in: 1 ... 3, using: &generator)).map { _ in previewTimeplace(using: &generator) },
            lectureNumber: "00\(Int.random(in: 1 ... 9, using: &generator))",
            instructor: instructorNames.randomElement(using: &generator)!,
            credit: Int64.random(in: 1 ... 4, using: &generator),
            department: departments.randomElement(using: &generator)!,
            academicYear: "\(Int.random(in: 1 ... 4, using: &generator))학년",
            evLecture: .init(evLectureID: 2, avgRating: 3.2, evaluationCount: 20),
            remark: remarks.randomElement(using: &generator)!
        )
    }

    private static func previewTimeplace<T: RandomNumberGenerator>(using generator: inout T) -> TimePlace {
        let day = Weekday.allCases.randomElement(using: &generator)!
        let startTime = Time(hour: Int.random(in: 9 ... 18, using: &generator), minute: [0, 15, 30, 45].randomElement(using: &generator)!)
        let endTime = Time(hour: startTime.hour + Int.random(in: 1 ... 3, using: &generator), minute: [0, 15, 30, 45].randomElement(using: &generator)!)
        let places = ["Room 101", "Room 202", "Room 303"]
        return TimePlace(
            id: UUID().uuidString,
            day: day,
            startTime: startTime,
            endTime: endTime,
            place: places.randomElement(using: &generator)!
        )
    }

    private static let remarks = [
        "Korean only.",
        "English only.",
    ]

    private static let departments = [
        "컴퓨터공학부",
        "수학과",
        "경제학부",
        "경영학과",
        "Physics",
        "지구환경과학부",
    ]

    private static let timetableTitles = [
        "시간표 1",
        "시간표 2",
        "Timetable",
        "망한시간표",
        "후보 1",
        "후보 2",
    ]

    private static let instructorNames = [
        "박찬국",
        "이승준",
        "김민수",
        "박신홍",
        "최유림",
        "이채민",
    ]

    private static let courseTitles = [
        "Introduction to Computer Science",
        "Calculus II",
        "고급항공전자 (복합항법시스템(Integrated Navigation System))",
        "컴퓨터 프로그래밍",
        "Physics I",
        "언어와 사고",
        "논리설계",
        "자료구조",
    ]

    private static let quarters = [
        Quarter(year: 2022, semester: .first),
        Quarter(year: 2022, semester: .second),
        Quarter(year: 2022, semester: .summer),
        Quarter(year: 2022, semester: .winter),
        Quarter(year: 2023, semester: .first),
        Quarter(year: 2023, semester: .second),
        Quarter(year: 2023, semester: .summer),
        Quarter(year: 2023, semester: .winter),
        Quarter(year: 2024, semester: .first),
    ]
}

@MemberwiseInit(.public)
public struct PreviewTimetable: Timetable {
    public var id: String = UUID().uuidString
    public let title: String
    public let quarter: Quarter
    public let lectures: [any Lecture]
    public let userID: String

    public func encode(to _: any Encoder) throws {}
    public init(from _: any Decoder) throws { fatalError() }
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

public struct PreviewTimetableMetadata: TimetableMetadata {
    public var id: String
    public var title: String
    public var quarter: Quarter
    public var totalCredit: Int
    public var isPrimary: Bool
}

private struct DeterministicRandomNumberGenerator: RandomNumberGenerator {
    private let randomSource: GKMersenneTwisterRandomSource

    init(seed: Int) {
        let seed = seed < 0 ? UInt64(bitPattern: Int64(seed)) : UInt64(seed)
        randomSource = GKMersenneTwisterRandomSource(seed: UInt64(seed))
    }

    mutating func next() -> UInt64 {
        let upperBits = UInt64(UInt32(bitPattern: Int32(randomSource.nextInt()))) << 32
        let lowerBits = UInt64(UInt32(bitPattern: Int32(randomSource.nextInt())))
        return upperBits | lowerBits
    }
}
