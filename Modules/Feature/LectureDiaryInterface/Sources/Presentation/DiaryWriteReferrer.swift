#if FEATURE_LECTURE_DIARY
//
//  DiaryWriteReferrer.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// Where the user entered the diary write screen from. `rawValue` is the value recorded to analytics.
public enum DiaryWriteReferrer: String, Sendable {
    /// Push notification or `snutt://diary` deep link.
    case push
    /// The diary history screen.
    case history
}
#endif
