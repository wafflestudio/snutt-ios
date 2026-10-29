//
//  EvaluationSearchFilter.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

enum EvaluationSearchFilterCategory: String, CaseIterable, Identifiable {
    case classification
    case department
    case academicYear
    case credit
    case time
    case category
    case etc

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classification: "분류"
        case .department: "학과"
        case .academicYear: "학년"
        case .credit: "학점"
        case .time: "시간"
        case .category: "교양분류"
        case .etc: "기타"
        }
    }
}

struct EvaluationSearchFilter: Hashable, Identifiable {
    let category: EvaluationSearchFilterCategory
    let title: String

    var id: String { "\(category.rawValue)-\(title)" }

    static let previewSelected = [
        EvaluationSearchFilter(category: .academicYear, title: "1학년"),
        EvaluationSearchFilter(category: .department, title: "디자인과"),
        EvaluationSearchFilter(category: .credit, title: "3학점"),
        EvaluationSearchFilter(category: .credit, title: "2학점"),
    ]

    static func options(for category: EvaluationSearchFilterCategory) -> [EvaluationSearchFilter] {
        let titles: [String]
        switch category {
        case .classification:
            titles = ["전공선택", "전공필수", "교양", "일반선택"]
        case .department:
            titles = ["AI융합교육과", "건축학과", "간호학과(간호학전공)", "건설환경공학부", "디자인과", "컴퓨터공학부"]
        case .academicYear:
            titles = ["1학년", "2학년", "3학년", "4학년"]
        case .credit:
            titles = ["1학점", "2학점", "3학점", "4학점"]
        case .time:
            titles = ["월요일", "화요일", "수요일", "목요일", "금요일"]
        case .category:
            titles = ["문학과 예술", "역사와 철학", "사회와 이념", "자연과 기술", "생명과 환경"]
        case .etc:
            titles = ["영강", "군휴학", "원격수업", "성적평가 완화"]
        }
        return titles.map { EvaluationSearchFilter(category: category, title: $0) }
    }
}
