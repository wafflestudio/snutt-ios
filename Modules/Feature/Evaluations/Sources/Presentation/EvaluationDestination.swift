//
//  EvaluationDestination.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

enum EvaluationDestination: Hashable {
    /// A lecture's evaluations, optionally scrolling to and highlighting one of them.
    case lectureDetail(EvaluationLectureID, highlighting: EvaluationID? = nil, referrer: ReviewDetailReferrer)
    case myEvaluations
    case allEvaluations(initialSort: EvaluationSort, availableSorts: [EvaluationSort])
}

/// A request to present the evaluation form for a lecture.
struct EvaluationWriteRequest: Identifiable, Hashable {
    let lectureID: EvaluationLectureID

    var id: EvaluationLectureID { lectureID }
}

/// An action the user picked from an evaluation's menu.
enum EvaluationMenuAction: Equatable {
    case edit(LectureEvaluation)
    case report(EvaluationID)
    case delete(EvaluationID)
}
