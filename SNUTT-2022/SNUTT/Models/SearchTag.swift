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
    init(from dto: SearchTagListDto) {
        let dtoDict = dto.asDictionary()! // TODO: remove force unwrapping
        var searchTags: [SearchTag] = []
        for (key, value) in dtoDict {
            guard let tagStrings = value as? [String],
                  let tagType = SearchTagType(rawValue: key) else { continue }
            searchTags.append(contentsOf: tagStrings.map { SearchTag(type: tagType, text: $0) })
        }

        // 기타 태그는 직접 추가해주어야 한다.
        searchTags.append(.init(type: .etc, text: EtcType.empty.rawValue))
        searchTags.append(.init(type: .etc, text: EtcType.english.rawValue))
        searchTags.append(.init(type: .etc, text: EtcType.army.rawValue))

        tagList = searchTags
        updatedAt = dto.updated_at
    }
}

enum SearchTagType: String, CaseIterable {
    case classification
    case department
    case academicYear = "academic_year"
    case credit
    case category
    case etc

    var tagColor: Color {
        switch self {
        case .academicYear: return Color(hex: "#dc2f45")
        case .classification: return Color(hex: "#e5731c")
        case .credit: return Color(hex: "#8bbb1a")
        case .department: return Color(hex: "#0cada6")
        case .category: return Color(hex: "#9c45a0")
        case .etc: return Color(hex: "#AF56B3")
        }
    }

    var tagLightColor: Color {
        switch self {
        case .academicYear: return Color(hex: "#e54459")
        case .classification: return Color(hex: "#f58d3d")
        case .credit: return Color(hex: "#a6d930")
        case .department: return Color(hex: "#1bd0c9")
        case .category: return Color(hex: "#af56b3")
        case .etc: return Color(hex: "#AF56B3")
        }
    }

    var typeStr: String {
        switch self {
        case .academicYear: return "학년"
        case .classification: return "분류"
        case .credit: return "학점"
        case .department: return "학과"
        case .category: return "교양분류"
        case .etc: return "기타"
        }
    }
}

enum EtcType: String {
    case empty = "빈 시간대"
    case english = "영어진행 강의"
    case army = "군휴학 원격수업"

    var code: String? {
        switch self {
        case .empty:
            return nil // should not be included in parameters; use timeMasks instead
        case .english:
            return "E"
        case .army:
            return "MO"
        }
    }
}
