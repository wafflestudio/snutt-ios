//
//  NotificationList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import SwiftUI

struct NotificationList: View {
    let notifications: [Notification]
    let initialFetch: () async -> Void
    let fetchMore: () async -> Void
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(notifications, id: \.hashValue) { notification in
                    NotificationListCell(notification: notification)
                        .task {
                            if notification.hashValue == notifications.last?.hashValue {
                                await fetchMore()
                            }
                        }
                }
            }
            .animation(.customSpring, value: notifications)
        }
        .background(STColor.systemBackground)
        .task {
            await initialFetch()
        }
    }
}
