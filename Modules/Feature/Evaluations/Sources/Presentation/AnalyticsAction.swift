//
//  AnalyticsAction.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

enum AnalyticsAction: AnalyticsLogEvent {
    case searchReview(LectureSearchQuery)
    case writeReview(lectureID: EvaluationLectureID)
    case editReview(evaluationID: EvaluationID)
    case deleteReview(evaluationID: EvaluationID)
    case reportReview(evaluationID: EvaluationID)
    case likeReview(evaluationID: EvaluationID, isLiked: Bool)

    var eventName: String {
        switch self {
        case .searchReview:
            "search_review"
        case .writeReview:
            "write_review"
        case .editReview:
            "edit_review"
        case .deleteReview:
            "delete_review"
        case .reportReview:
            "report_review"
        case .likeReview(_, let isLiked):
            isLiked ? "like_review" : "unlike_review"
        }
    }

    var parameters: [String: String]? {
        switch self {
        case .searchReview(let query):
            ["query": query.text, "tags": query.tags.map(\.name).joined(separator: ",")]
        case .writeReview(let lectureID):
            ["evLectureID": lectureID.description]
        case .editReview(let evaluationID),
            .deleteReview(let evaluationID),
            .reportReview(let evaluationID),
            .likeReview(let evaluationID, _):
            ["evaluationID": evaluationID.description]
        }
    }
}
