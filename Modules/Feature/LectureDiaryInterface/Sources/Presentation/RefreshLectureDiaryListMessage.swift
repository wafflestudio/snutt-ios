#if FEATURE_LECTURE_DIARY
//
//  RefreshLectureDiaryListMessage.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesUtility
import Foundation

public struct RefreshLectureDiaryListMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("refreshLectureDiaryList")

    public init() {}
}
#endif
