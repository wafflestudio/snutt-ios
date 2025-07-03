//
//  DailyReview.swift
//  SNUTT
//
//  Created by 최유림 on 5/28/25.
//

import Foundation

// FIXME: change scheme
struct DailyReview: Hashable {
    let lectureTitle: String
    let date: Date
    let year: Int
    let semester: Int
    let content: [String: String]
    var comment: String? = nil
}

#if DEBUG
extension DailyReview {
    static let debug: Self = .init(
        lectureTitle: "시각디자인기초",
        date: .now,
        year: 2024,
        semester: 1,
        content: [
            "수강신청": "널널해요",
            "드랍여부": "모르겠어요",
            "수업 첫인상": "두려워요"
        ],
        comment: "오티 했어용. 교수님이 과제량 많다고 하셨는데 도움이 많이 될 것 같아 기대가 돼요. 수업 들으려고 과외도 끊었지 뭐에요 😮‍💨"
    )
}
#endif
