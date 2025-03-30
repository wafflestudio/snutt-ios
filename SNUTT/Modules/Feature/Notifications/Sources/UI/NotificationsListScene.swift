//
//  NotificationsListScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SwiftUIUtility
import SharedUIComponents
import Dependencies

public struct NotificationsListScene: View {
    @State private var viewModel = NotificationsViewModel()
    @State private var scrolledID: String?
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Dependency(\.application) private var application

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.notifications) { notification in
                    NotificationListCell(notification: notification)
                        .onTapGesture {
                            if let link = notification.deeplink
                            {
                                Task {
                                    await application.open(link)
                                }
                            }
                        }
                        .highlightOnPress()

                    Divider()
                        .frame(height: 1)
                        .padding(.leading, 15)
                }
            }
            .scrollTargetLayout()
        }
        .withResponsiveTouch()
        .navigationTitle("알림")
        .scrollPosition(id: $scrolledID, anchor: .bottom)
        .onChange(of: scrolledID) { _, _ in
            if viewModel.notifications.suffix(5).map({ $0.id }).contains(scrolledID) {
                errorAlertHandler.withAlert {
                    try await viewModel.fetchMoreNotifications()
                }
            }
        }
        .onLoad {
            await errorAlertHandler.withAlert {
                try await viewModel.fetchInitialNotifications()
            }
        }
    }
}


#Preview {
    NotificationsListScene()
}
