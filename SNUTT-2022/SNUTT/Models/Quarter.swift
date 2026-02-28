//
//  Quarter.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation

struct Quarter {
    var year: Int
    var semester: Semester
    var updatedAt: String?

    func shortString() -> String {
        return String(year) + semester.shortString()
    }

    /// 예: "2022년 겨울학기"
    func longString() -> String {
        return "\(year)년 \(semester.longString())"
    }
}

extension Quarter: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(year)
        hasher.combine(semester)
    }
}

extension Quarter: Equatable {
    static func == (lhs: Quarter, rhs: Quarter) -> Bool {
        return lhs.year == rhs.year && lhs.semester == rhs.semester
    }
}

extension Quarter: Comparable {
    static func < (lhs: Quarter, rhs: Quarter) -> Bool {
        return (lhs.year, lhs.semester.rawValue) < (rhs.year, rhs.semester.rawValue)
    }
}

extension Quarter {
    init(from dto: CourseBookDto) {
        year = dto.year
        semester = Semester(rawValue: dto.semester) ?? .first
        updatedAt = dto.updated_at
    }
}

enum Semester: Int {
    case first = 1, summer, second, winter

    func shortString() -> String {
        switch self {
        case .first: return "1"
        case .second: return "2"
        case .summer: return "S"
        case .winter: return "W"
        }
    }
    
    func mediumString() -> String {
        switch self {
        case .first: return "1"
        case .second: return "2"
        case .summer: return "여름"
        case .winter: return "겨울"
        }
    }

    func longString() -> String {
        switch self {
        case .first: return "1학기"
        case .second: return "2학기"
        case .summer: return "여름학기"
        case .winter: return "겨울학기"
        }
    }
}
