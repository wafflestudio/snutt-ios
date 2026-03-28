//
//  AppReviewRequester.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

protocol AppReviewRequester: Sendable {
    func requestReview()
}

protocol AppReviewStoreURLHandler: Sendable {
    func openReviewPage()
}
