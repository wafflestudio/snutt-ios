//
//  EvaluationDestination.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

enum EvaluationDestination: Hashable {
    case search
    case filter
    case evaluationDetail(EvaluationID)
    case lectureDetail(EvaluationLectureID)
    case writeEvaluation(EvaluationLectureID)
    case myEvaluations
    case allEvaluations(sort: EvaluationSort.Kind)
}
