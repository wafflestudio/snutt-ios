//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

public enum AnalyticsScreen: AnalyticsLogEvent {
    case reviewHome
    case reviewSearch
    case reviewFilter
    case reviewDetail(evLectureID: Int64, referrer: ReviewDetailReferrer)
    case reviewAll(sort: String)
    case myReviews
    case reviewWrite(evLectureID: Int64)
    case reviewEdit(evaluationID: Int64)
    case reviewEmailVerification

    public var eventName: String {
        switch self {
        case .reviewHome:
            "review_home"
        case .reviewSearch:
            "review_search"
        case .reviewFilter:
            "review_filter"
        case .reviewDetail:
            "review_detail"
        case .reviewAll:
            "review_all"
        case .myReviews:
            "my_reviews"
        case .reviewWrite:
            "review_write"
        case .reviewEdit:
            "review_edit"
        case .reviewEmailVerification:
            "review_email_verification"
        }
    }

    public var parameters: [String: String]? {
        switch self {
        case .reviewHome, .reviewSearch, .reviewFilter, .myReviews, .reviewEmailVerification:
            nil
        case .reviewDetail(let evLectureID, let referrer):
            ["evLectureID": evLectureID.description, "referrer": referrer.description]
        case .reviewAll(let sort):
            ["sort": sort]
        case .reviewWrite(let evLectureID):
            ["evLectureID": evLectureID.description]
        case .reviewEdit(let evaluationID):
            ["evaluationID": evaluationID.description]
        }
    }
}

/// Where a lecture's evaluations were opened from within the evaluation tab.
public enum ReviewDetailReferrer: Hashable, Sendable, CustomStringConvertible {
    case feed
    case takenLecture
    case myReviews
    case search(query: String)
    case write

    public var description: String {
        switch self {
        case .feed:
            "feed"
        case .takenLecture:
            "takenLecture"
        case .myReviews:
            "myReviews"
        case .search(let query):
            "search=\(query)"
        case .write:
            "write"
        }
    }
}
