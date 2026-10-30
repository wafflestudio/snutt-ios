//
//  EvaluationDisplayFormatting.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import TimetableInterface

enum EvaluationDesignColor {
    static var accent: Color { SharedUIComponentsAsset.cyan.swiftUIColor }
    static var accentBackground: Color { accent.opacity(0.08) }
    static var star: Color { Color(red: 1.0, green: 0.76, blue: 0.0) }
    static var emptyStar: Color { Color(uiColor: .systemGray4) }
    static var sectionSeparator: Color { Color(uiColor: .secondarySystemBackground) }
}

extension Quarter {
    /// A short label such as "25년 2학기".
    var evaluationDisplayText: String {
        EvaluationsStrings.quarter(String(year % 100), semester.evaluationDisplayText)
    }
}

extension Semester {
    var evaluationDisplayText: String {
        switch self {
        case .first: EvaluationsStrings.semesterFirst
        case .summer: EvaluationsStrings.semesterSummer
        case .second: EvaluationsStrings.semesterSecond
        case .winter: EvaluationsStrings.semesterWinter
        }
    }
}

extension EvaluationSort.Kind {
    var displayTitle: String {
        switch self {
        case .recommended: EvaluationsStrings.sortRecommended
        case .latest: EvaluationsStrings.sortLatest
        }
    }
}

extension EvaluationCriterion {
    var displayTitle: String {
        switch self {
        case .gradeSatisfaction: EvaluationsStrings.criterionGradeSatisfaction
        case .teachingSkill: EvaluationsStrings.criterionTeachingSkill
        case .gains: EvaluationsStrings.criterionGains
        case .lifeBalance: EvaluationsStrings.criterionLifeBalance
        }
    }

    var question: String {
        switch self {
        case .gradeSatisfaction: EvaluationsStrings.writeCriterionGradeSatisfaction
        case .teachingSkill: EvaluationsStrings.writeCriterionTeachingSkill
        case .gains: EvaluationsStrings.writeCriterionGains
        case .lifeBalance: EvaluationsStrings.writeCriterionLifeBalance
        }
    }
}

extension EvaluationLectureBrief {
    var instructorDisplayText: String {
        instructor ?? EvaluationsStrings.lectureInstructorUnknown
    }
}

extension EvaluationLectureInfo {
    /// A line such as "컴퓨터공학부 · 전선 · 3학점", omitting missing parts.
    var metadataText: String {
        [department, classification, credit.map(EvaluationsStrings.lectureCredit)]
            .compactMap { $0 }
            .joined(separator: " · ")
    }
}

extension Double {
    /// A rating such as "4.5".
    var ratingText: String {
        formatted(.number.precision(.fractionLength(1)))
    }
}

extension String {
    /// Joins lines with single spaces so a truncated preview isn't padded with blank lines.
    var singleLinePreview: String {
        replacing(/\s*\n\s*/, with: " ")
    }
}
