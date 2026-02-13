//
//  SearchPredicate.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

enum SearchPredicate: Sendable, Hashable {
    case sortCriteria(String)
    case classification(String)
    case department(String)
    case academicYear(String)
    case credit(Int)
    case instructor(String)
    case category(String)
    case categoryPre2025(String)
    case timeInclude(SearchTimeRange)
    case timeExclude(SearchTimeRange)
    case etc(EtcType)
}

struct SearchTimeRange: Codable, Hashable, Sendable {
    let day: Int
    let startMinute: Int
    let endMinute: Int
}

enum EtcType: String, Sendable {
    case english
    case army

    var code: String {
        switch self {
        case .english:
            return "E"
        case .army:
            return "MO"
        }
    }
}
