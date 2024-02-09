//
//  NotificationList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import SwiftUI

struct NotificationList: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        List {
            ForEach(viewModel.notifications, id: \.hashValue) { notification in
                NotificationListCell(notification: notification, colorScheme: colorScheme)
                    .task {
                        if notification.hashValue == viewModel.notifications.last?.hashValue {
                            await viewModel.fetchMoreNotifications()
                        }
                    }
                    .listRowBackground(STColor.systemBackground)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }
        }
        .padding(.horizontal, 16)
        .listStyle(.plain)
        .navigationTitle(Text("알림"))
        .navigationBarTitleDisplayMode(.inline)
        .background(STColor.systemBackground)
        .task {
            await viewModel.fetchInitialNotifications(updateLastRead: true)
        }
    }
}

extension NotificationList {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published private(set) var notifications: [STNotification] = []

        override init(container: DIContainer) {
            super.init(container: container)
            appState.notification.$notifications.assign(to: &$notifications)
        }

        func fetchInitialNotifications(updateLastRead: Bool) async {
            do {
                try await services.notificationService.fetchInitialNotifications(updateLastRead: updateLastRead)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func fetchMoreNotifications() async {
            do {
                try await services.notificationService.fetchMoreNotifications()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

#if DEBUG
    struct NotificationList_Previews: PreviewProvider {
        static var notifications: [STNotification] {
            return [
                .init(title: "공지", message: "공지예시 1", created_at: "2022-04-30T08:11:04.200Z", type: .normal, user_id: ""),
                .init(title: "공지", message: "공지예시 2", created_at: "2022-04-30T08:11:04.201Z", type: .normal, user_id: ""),
                .init(title: "공지", message: "공지예시 3", created_at: "2022-04-30T08:11:04.202Z", type: .normal, user_id: ""),
            ]
        }

        static var previews: some View {
            let container: DIContainer = {
                let container = DIContainer.preview
                container.appState.notification.notifications = Self.notifications
                return container
            }()
            NotificationList(viewModel: .init(container: container))
        }
    }
#endif
