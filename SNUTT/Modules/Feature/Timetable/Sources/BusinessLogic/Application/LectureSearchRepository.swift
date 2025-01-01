//
//  LectureSearchRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import Spyable
import TimetableInterface

@Spyable
protocol LectureSearchRepository: Sendable {
//    func fetchTags(quarter: Quarter) async throws -> SearchTagListDto
    func fetchSearchResult(
        query: String,
        quarter: Quarter,
        filters: [SearchFilter],
        offset: Int,
        limit: Int
    ) async throws -> [any Lecture]
}

enum SearchFilter: Sendable {
    case sortCriteria(String)
    case classification(String)
    case department(String)
    case academicYear(String)
    case credit(Int)
    case timeInclude(SearchTimeFilter)
    case timeExclude(SearchTimeFilter)
    case category(String)
    case etc(EtcType)
}

struct SearchTimeFilter: Codable, Hashable {
    let day: Int
    let startMinute: Int
    let endMinute: Int
}

enum EtcType: String {
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
