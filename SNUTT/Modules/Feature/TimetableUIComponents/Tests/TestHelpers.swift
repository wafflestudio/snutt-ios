//
//  TestHelpers.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import FoundationUtility
import ThemesInterface
import TimetableInterface

@testable import TimetableUIComponents

// MARK: - TimetablePainter

extension TimetablePainter {
    static func stub(
        timetable: Timetable? = nil,
        selectedLecture: Lecture? = nil,
        preferredTheme: Theme? = nil,
        availableThemes: [Theme] = [],
        configuration: TimetableConfiguration = .init()
    ) -> TimetablePainter {
        TimetablePainter(
            currentTimetable: timetable,
            selectedLecture: selectedLecture,
            preferredTheme: preferredTheme,
            availableThemes: availableThemes,
            configuration: configuration
        )
    }
}

// MARK: - Timetable

extension Timetable {
    static func stub(
        id: String = "test",
        lectures: [Lecture] = [],
        theme: ThemeType = .builtInTheme(.snutt)
    ) -> Timetable {
        Timetable(
            id: id,
            title: "Test Timetable",
            quarter: .init(year: 2025, semester: .first),
            lectures: lectures,
            userID: "user",
            theme: theme
        )
    }
}

// MARK: - Lecture

extension Lecture {
    static func stub(
        id: String = UUID().uuidString,
        lectureID: String = "1",
        courseTitle: String = "Test Course",
        timePlaces: [TimePlace] = [],
        colorIndex: Int = 0,
        customColor: LectureColor? = nil
    ) -> Lecture {
        Lecture(
            id: id,
            lectureID: lectureID,
            courseTitle: courseTitle,
            timePlaces: timePlaces,
            lectureNumber: nil,
            instructor: nil,
            credit: 3,
            courseNumber: nil,
            department: nil,
            academicYear: nil,
            remark: nil,
            evLecture: nil,
            colorIndex: colorIndex,
            customColor: customColor,
            classification: nil,
            category: nil,
            wasFull: false,
            registrationCount: 0,
            quota: nil,
            freshmenQuota: nil
        )
    }
}

// MARK: - TimePlace

extension TimePlace {
    static func stub(
        day: Weekday,
        startHour: Int,
        startMinute: Int = 0,
        endHour: Int,
        endMinute: Int = 0,
        place: String = "Test Place",
        isCustom: Bool = false
    ) -> TimePlace {
        TimePlace(
            id: UUID().uuidString,
            day: day,
            startTime: .init(hour: startHour, minute: startMinute),
            endTime: .init(hour: endHour, minute: endMinute),
            place: place,
            isCustom: isCustom
        )
    }
}
