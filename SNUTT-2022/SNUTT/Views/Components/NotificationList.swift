//
//  NotificationList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import SwiftUI

struct NotificationList: View {
    let notifications: [STNotification]
    let initialFetch: (Bool) async -> Void
    let fetchMore: () async -> Void
    var body: some View {
        List {
            ForEach(notifications, id: \.hashValue) { notification in
                NotificationListCell(notification: notification)
                    .task {
                        if notification.hashValue == notifications.last?.hashValue {
                            await fetchMore()
                        }
                    }
                    .listRowBackground(STColor.systemBackground)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Text("알림"))
        .navigationBarTitleDisplayMode(.inline)
        .background(STColor.systemBackground)
        .task {
            await initialFetch(true)
        }
    }
}

#if DEBUG
    struct NotificationList_Previews: PreviewProvider {
        static var notifications: [STNotification] {
            return [
                .init(message: "공지", created_at: "2022-04-30T08:11:04.200Z", type: .normal, user_id: ""),
                .init(message: "공지", created_at: "2022-04-30T08:11:04.201Z", type: .normal, user_id: ""),
                .init(message: "공지", created_at: "2022-04-30T08:11:04.202Z", type: .normal, user_id: ""),
            ]
        }

        static var previews: some View {
            NotificationList(notifications: notifications) { _ in

            } fetchMore: {}
        }
    }
#endif
