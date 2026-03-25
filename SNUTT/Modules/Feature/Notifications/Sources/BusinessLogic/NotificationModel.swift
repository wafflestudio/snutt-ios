//
//  NotificationModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Foundation
import Tagged

struct NotificationModel: Sendable, Identifiable {
    let id: String
    let title: String
    let message: String
    let createdAt: Date
    let type: NotificationType
    let userID: UserID?
    let deeplink: URL?
}

enum NotificationType: Int {
    case normal = 0
    case courseBook, lectureUpdate, lectureRemove, lectureVacancy, friend, newFeature
}
