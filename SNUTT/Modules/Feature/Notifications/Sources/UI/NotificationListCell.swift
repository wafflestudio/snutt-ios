//
//  NotificationListCell.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import SwiftUI
import SwiftUIUtility

struct NotificationListCell: View {
    let notification: NotificationModel

    private enum Design {
        static let titleFont: Font = .system(size: 14, weight: .semibold)
        static let messageFont: Font = .system(size: 14)
        static let dateFont: Font = .system(size: 12)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                notification.type.iconImage
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .offset(x: 0, y: -6)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Text(notification.title.nilIfEmpty ?? notification.type.defaultTitle)
                            .font(Design.titleFont)

                        Spacer()

                        Text(notification.createdAt.localizedDateString(dateStyle: .short, timeStyle: .short))
                            .font(Design.dateFont)
                            .foregroundColor(Color(uiColor: .tertiaryLabel))
                    }

                    Spacer().frame(height: 6)

                    Text(notification.message)
                        .font(Design.messageFont)
                        .padding(.trailing, 8)
                    #if DEBUG
                        if let deeplink = notification.deeplink {
                            Text("[DEBUG] 🔗 \(deeplink)")
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                                .padding(.top, 5)
                        }
                    #endif
                }
                .padding(.trailing, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Color.label)
        .padding(.vertical, 15)
        .padding(.horizontal, 15)
        .contentShape(.rect)
    }
}

extension NotificationType {
    fileprivate var iconImage: Image {
        switch self {
        case .normal:
            NotificationsAsset.notiExclamation.swiftUIImage
        case .courseBook:
            NotificationsAsset.notiCalendar.swiftUIImage
        case .lectureUpdate:
            NotificationsAsset.notiRefresh.swiftUIImage
        case .lectureRemove:
            NotificationsAsset.notiTrash.swiftUIImage
        case .lectureVacancy:
            NotificationsAsset.notiVacancy.swiftUIImage
        case .friend:
            NotificationsAsset.notiFriend.swiftUIImage
        case .newFeature:
            NotificationsAsset.notiMegaphone.swiftUIImage
        }
    }

    fileprivate var defaultTitle: String {
        switch self {
        case .normal:
            NotificationsStrings.notificationTypeNormal
        case .courseBook:
            NotificationsStrings.notificationTypeCourseBook
        case .lectureUpdate:
            NotificationsStrings.notificationTypeLectureUpdate
        case .lectureRemove:
            NotificationsStrings.notificationTypeLectureRemove
        case .lectureVacancy:
            NotificationsStrings.notificationTypeLectureVacancy
        case .friend:
            NotificationsStrings.notificationTypeFriend
        case .newFeature:
            NotificationsStrings.notificationTypeNewFeature
        }
    }
}
