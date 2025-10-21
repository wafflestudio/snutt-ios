//
//  ReviewsUIProvider.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import ReviewsInterface
import SwiftUI

public struct ReviewsUIProvider: ReviewsUIProvidable {
    public nonisolated init() {}
    public func makeReviewsScene(for evLectureID: Int) -> AnyView {
        AnyView(ReviewsScene(evLectureID: evLectureID))
    }
}
