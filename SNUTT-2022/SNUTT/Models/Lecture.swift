//
//  Lecture.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import Foundation
import SwiftUI

struct Lecture: Identifiable {
    let id: String
    let lectureId: String?
    var title: String
    var instructor: String
    var timePlaces: [TimePlace]
    var courseNumber: String
    var lectureNumber: String
    var credit: Int
    var department: String
    var academicYear: String
    var colorIndex: Int
    var classification: String
    var category: String
    var remark: String
    var isCustom: Bool
    var color: LectureColor?
    var nonFreshmanQuota: Int {
        quota - freshmanQuota
    }

    var createdAt: String
    var updatedAt: String
    var quota: Int
    var freshmanQuota: Int
    var registrationCount: Int?
    var wasFull: Bool

    /// init 시에 ThemeDto의 theme 정보를 lecture에 저장
    var basicTheme: BasicTheme?
    var lectureIndex: Int

    func withTheme(theme: Int?) -> Lecture {
        var lecture = self
        lecture.basicTheme = BasicTheme(rawValue: theme ?? 0)
        return lecture
    }

    func getColor(with theme: Theme? = nil) -> LectureColor {
        // use custom color list if theme is custom
        if let theme = theme, !theme.colors.isEmpty {
            return theme.colors[(lectureIndex - 1) % theme.colors.count]
        }

        // use color specified by colorIndex, where theme is given by parameter
        if let color = theme?.theme?.getColor(at: lectureIndex) {
            return color
        }

        // use custom color if colorIndex is zero
        if colorIndex == 0, let color = color {
            return color
        }

        if let color = basicTheme?.getColor(at: colorIndex) {
            return color
        }

        return .temporary
    }

    func withTemporaryColor() -> Self {
        var lecture = self
        lecture.color = .temporary
        lecture.colorIndex = 0
        return lecture
    }

    func withOccupiedColor(colorScheme: ColorScheme) -> Self {
        var lecture = self
        lecture.color = colorScheme == .dark ? .occupiedDark : .occupiedLight
        lecture.colorIndex = 0
        return lecture
    }

    func withSelectedColor() -> Self {
        var lecture = self
        lecture.color = .selected
        lecture.colorIndex = 0
        return lecture
    }

    var preciseTimeString: String {
        if timePlaces.isEmpty {
            return ""
        }
        return timePlaces.map { $0.preciseTimeString }.joined(separator: ", ")
    }

    var placesString: String {
        if timePlaces.isEmpty {
            return ""
        }
        let places = timePlaces
            .compactMap { $0.place.isEmpty ? nil : $0.place }
            .reduce(into: Set<String>()) { $0.insert($1) }
        if places.isEmpty {
            return ""
        }
        return places.joined(separator: ", ")
    }

    var hasVacancy: Bool {
        guard let current = registrationCount else { return false }
        return wasFull && current < quota
    }

    func isEquivalent(with lecture: Lecture) -> Bool {
        if isCustom {
            return id == lecture.id
        }
        return courseNumber == lecture.courseNumber && lectureNumber == lecture.lectureNumber
    }
}

struct LectureColor: Hashable {
    var fg: Color
    var bg: Color

    static let temporary: Self = .init(fg: .black, bg: .init(red: 196 / 255, green: 196 / 255, blue: 196 / 255))

    static let occupiedLight: Self = .init(fg: .white, bg: STColor.gray10.opacity(0.7))

    static let occupiedDark: Self = .init(fg: STColor.darkGray, bg: STColor.darkerGray.opacity(0.7))

    /// SNUTT cyan (light)
    static let selected: Self = .init(fg: .clear, bg: .init(hex: "#1BD0C8").opacity(0.6))
}

extension Lecture {
    init(from dto: LectureDto, index: Int? = nil) {
        id = dto._id
        lectureId = dto.lecture_id
        title = dto.course_title
        instructor = dto.instructor
        timePlaces = dto.class_time_json.map { .init(from: $0, isCustom: dto.isCustom) }
        isCustom = dto.isCustom
        courseNumber = dto.course_number ?? ""
        lectureNumber = dto.lecture_number ?? ""
        credit = dto.credit
        department = dto.department ?? ""
        academicYear = dto.academic_year ?? ""
        colorIndex = dto.colorIndex ?? 1
        classification = dto.classification ?? ""
        category = dto.category ?? ""
        remark = dto.remark ?? ""
        quota = dto.quota ?? 0
        freshmanQuota = dto.freshmanQuota ?? 0
        createdAt = dto.created_at ?? ""
        updatedAt = dto.updated_at ?? ""
        if let colorDto = dto.color, let fg = colorDto.fg, let bg = colorDto.bg {
            color = .init(fg: .init(hex: fg), bg: .init(hex: bg))
        }
        freshmanQuota = dto.freshmanQuota ?? 0
        registrationCount = dto.registrationCount
        wasFull = dto.wasFull ?? false
        lectureIndex = (index ?? 0) + 1
    }
}

#if DEBUG
    extension Lecture {
        static var preview: Lecture {
            let instructors = ["염헌영", "엄현상", "김진수", "김형주", "이영기", "배영애", "유성호"]
            let titles = ["시스템프로그래밍", "양궁", "죽음의 과학적 이해", "북한학개론", "Operating System"]
            let departments = ["경영학과", "컴퓨터공학과", "서양사학과", "디자인과"]
            let academicYears = ["1학년", "2학년", "3학년", "4학년"]
            return Lecture(id: UUID().uuidString,
                           lectureId: UUID().uuidString,
                           title: titles.randomElement()!,
                           instructor: instructors.randomElement()!,
                           timePlaces: [.preview, .preview, .preview, .preview, .preview],
                           courseNumber: "400.313",
                           lectureNumber: "001",
                           credit: Int.random(in: 0 ... 4),
                           department: departments.randomElement()!,
                           academicYear: academicYears.randomElement()!,
                           colorIndex: Int.random(in: 1 ... 5),
                           classification: "전선",
                           category: "체육",
                           remark: "영어강의, 복부전생수강불가, 주전공생수강불가, 어쩌구 저쩌구",
                           isCustom: false,
                           color: nil,
                           createdAt: "2022-04-02T16:35:53.652Z",
                           updatedAt: "2022-04-02T16:35:53.652Z",
                           quota: Int.random(in: 10 ... 100),
                           freshmanQuota: Int.random(in: 1 ... 10),
                           registrationCount: Int.random(in: 10 ... 100),
                           wasFull: false,
                           lectureIndex: 0)
        }
    }
#endif
