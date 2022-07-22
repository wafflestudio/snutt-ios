//
//  Quarter.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation

struct Quarter: Hashable {
    var year: Int
    var semester: Semester
    
    func shortString() -> String {
        return String(year) + semester.shortString()
    }

    func longString() -> String {
        return "\(year)년 \(semester.longString())"
    }
}

extension Quarter: Comparable {
    static func < (lhs: Quarter, rhs: Quarter) -> Bool {
        return (lhs.year, lhs.semester.rawValue) < (rhs.year, rhs.semester.rawValue)
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

    func longString() -> String {
        switch self {
        case .first: return "1학기"
        case .second: return "2학기"
        case .summer: return "여름학기"
        case .winter: return "겨울학기"
        }
    }
}
