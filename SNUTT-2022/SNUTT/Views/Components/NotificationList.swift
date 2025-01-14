//
//  NotificationList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import SwiftUI

struct NotificationList: View {
    @StateObject var viewModel: ViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        List {
            ForEach(viewModel.notifications, id: \.hashValue) { notification in
                Button {
                    if notification.type == .lectureUpdate,
                       let deeplink = notification.deeplink,
                       let url = URL(string: deeplink)
                    {
                        UIApplication.shared.open(url, options: [:])
                    }
                } label: {
                    NotificationListCell(notification: notification, colorScheme: colorScheme)
                        .task {
                            if notification.hashValue == viewModel.notifications.last?.hashValue {
                                await viewModel.fetchMoreNotifications()
                            }
                        }
                        .padding(.horizontal, 16)
                }
                .listRowBackground(STColor.systemBackground)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .buttonStyle(RectangleButtonStyle())
            }
        }
        .listStyle(.plain)
        .navigationTitle(Text("알림"))
        .navigationBarTitleDisplayMode(.inline)
        .background(STColor.systemBackground)
        .task {
            await viewModel.fetchInitialNotifications(updateLastRead: true)
        }
        .background {
            NavigationLink(
                destination: makeLectureDetailScene(),
                isActive: $viewModel.routingState.lectureDetailRoutingInfo.pushToLectureDetail,
                label: {
                    EmptyView()
                }
            )
        }
    }

    private func makeLectureDetailScene() -> some View {
        let routingInfo = viewModel.routingState.lectureDetailRoutingInfo
        return Group {
            if let lecture = routingInfo.lecture {
                ZStack {
                    LectureDetailScene(viewModel: .init(container: viewModel.container), lecture: lecture, displayMode: .preview(shouldHideDismissButton: true))
                    if let timetableId = routingInfo.timetableId {
                        VStack {
                            Spacer()
                            FloatingButton(text: "해당 시간표로 이동") {
                                Task {
                                    await viewModel.goToTimetableScene(with: timetableId)
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
    }
}

extension NotificationList {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published private(set) var notifications: [STNotification] = []

        override init(container: DIContainer) {
            super.init(container: container)
            appState.notification.$notifications.assign(to: &$notifications)
            appState.routing.$notificationList.assign(to: &$_routingState)
        }

        @Published var _routingState: NotificationList.RoutingState = .init()
        var routingState: NotificationList.RoutingState {
            get { _routingState }
            set {
                services.globalUIService.setRoutingState(\.notificationList, value: newValue)
            }
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

        func goToTimetableScene(with timetableId: String) async {
            do {
                let _ = try await services.timetableService.fetchTimetable(timetableId: timetableId)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
            NavigationUtil.popToRootView(animated: true)
        }
    }
}

@available(iOS, deprecated: 16.0, message: "Use NaviationStack instead. This will be removed in the future.")
struct NavigationUtil {
    static func popToRootView(animated: Bool = false) {
        findNavigationController(viewController: UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }?.rootViewController)?.popToRootViewController(animated: animated)
    }

    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }

        if let navigationController = viewController as? UITabBarController {
            return findNavigationController(viewController: navigationController.selectedViewController)
        }

        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }

        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }

        return nil
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
