//
//  SearchTag.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation
import SwiftUI

struct SearchTag: Identifiable {
    var id = UUID()
    var type: SearchTagType
    var text: String
}

struct SearchTagList {
    var tagList: [SearchTag]
    var updatedAt: Int64
}

extension SearchTagList {
    init?(from dto: SearchTagListDto) {
        guard let dtoDict = dto.asDictionary() else { return nil }
        var searchTags: [SearchTag] = []
        for (key, value) in dtoDict {
            guard let tagStrings = value as? [String],
                  let tagType = SearchTagType(rawValue: key) else { continue }
            searchTags.append(contentsOf: tagStrings.map { SearchTag(type: tagType, text: $0) })
        }

        // 시간
        searchTags.append(.init(type: .time, text: TimeType.empty.rawValue))
        searchTags.append(.init(type: .time, text: TimeType.range.rawValue))

        // 기타
        searchTags.append(.init(type: .etc, text: EtcType.english.rawValue))
        searchTags.append(.init(type: .etc, text: EtcType.army.rawValue))

        tagList = searchTags
        updatedAt = dto.updated_at
    }
}

enum SearchTagType: String, CaseIterable {
    case sortCriteria
    case classification
    case department
    case academicYear = "academic_year"
    case credit
    case time
    case category
    case etc

    var tagColor: Color {
        switch self {
        case .sortCriteria: return Color(hex: "#A6A6A6")
        case .academicYear: return Color(hex: "#E54459")
        case .classification: return Color(hex: "#F58D3D")
        case .credit: return Color(hex: "#A6D930")
        case .department: return Color(hex: "#1BD0C8")
        case .time: return Color(hex: "#1D99E8")
        case .category: return Color(hex: "#4F48C4")
        case .etc: return Color(hex: "#AF56B3")
        }
    }

    var typeStr: String {
        switch self {
        case .sortCriteria: return "정렬 기준"
        case .academicYear: return "학년"
        case .classification: return "분류"
        case .credit: return "학점"
        case .department: return "학과"
        case .time: return "시간"
        case .category: return "교양분류"
        case .etc: return "기타"
        }
    }
}

enum TimeType: String {
    case empty = "빈 시간대로 검색"
    case range = "시간대 직접 선택"
}

enum EtcType: String {
    case english = "영어진행 강의"
    case army = "군휴학 원격수업"

    var code: String? {
        switch self {
        case .english:
            return "E"
        case .army:
            return "MO"
        }
    }
}
