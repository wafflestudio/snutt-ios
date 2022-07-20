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
    
    func shortString() -> String {
        return String(year) + semester.shortString()
    }

    func longString() -> String {
        return String(year) + " " + semester.longString()
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
        case .first: return NSLocalizedString("first_semester", comment: "")
        case .second: return NSLocalizedString("second_semester", comment: "")
        case .summer: return NSLocalizedString("summer_semester", comment: "")
        case .winter: return NSLocalizedString("winter_semester", comment: "")
        }
    }
}
