//
//  NotificationModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

struct NotificationModel: Sendable, Identifiable {
    let id: String
    let title: String
    let message: String
    let createdAt: Date
    let type: NotificationType
    let userID: String?
    let deeplink: URL?
}

enum NotificationType: Int {
    case normal = 0
    case courseBook, lectureUpdate, lectureRemove, lectureVacancy, friend, newFeature
}
