//
//  MainContentView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import Friends
import Notifications
import NotificationsInterface
import Reviews
import Settings
import SharedUIComponents
import SwiftUI
import Timetable
import TimetableInterface
import Vacancy

#if DEBUG
    import APIClient
#endif

struct MainContentView: View {
    @State private var viewModel = MainContentViewModel()
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.presentToast) private var presentToast
    @AppStorage(AppStorageKeys.preferredColorScheme) private var selectedColorScheme: ColorSchemeSelection = .system

    var body: some View {
        ZStack {
            CommonTabView(selectedTab: $viewModel.selectedTab) {
                TabScene(
                    tabItem: TabItem.timetable,
                    rootView: TimetableScene(
                        timetableViewModel: viewModel.timetableViewModel
                    )
                    .environment(\.notificationsUIProvider, NotificationsUIProvider())
                )
                TabScene(
                    tabItem: TabItem.search,
                    rootView: LectureSearchScene(
                        timetableViewModel: viewModel.timetableViewModel
                    )
                )
                TabScene(
                    tabItem: TabItem.review,
                    rootView: ReviewsWebScene()
                        .modifier(AnalyticsScreenModifier(screen: Reviews.AnalyticsScreen.reviewHome))
                )
                TabScene(
                    tabItem: TabItem.friends,
                    rootView: FriendsScene()
                        .modifier(AnalyticsScreenModifier(screen: Friends.AnalyticsScreen.friends))
                )
                TabScene(
                    tabItem: TabItem.settings,
                    rootView: SettingsScene()
                        .environment(\.vacancyUIProvider, VacancyUIProvider())
                        #if DEBUG
                            .environment(\.networkLogUIProvider, NetworkLogUIProvider())
                        #endif
                )
            }
            .ignoresSafeArea()
        }
        .overlaySheet()
        .overlayPopup()
        .overlayADPopup()
        //        .overlayLectureDiarySheet(
        //            lectureId: viewModel.diaryLectureID,
        //            lectureTitle: viewModel.diaryLectureTitle
        //        )
        .task {
            for await message in viewModel.notificationCenter.messages(of: ToastNotificationMessage.self) {
                presentToast(message.toast)
            }
        }
        .environment(\.themeViewModel, viewModel.themeViewModel)
        .environment(\.timetableViewModel, viewModel.timetableViewModel)
        .onLoad {
            errorAlertHandler.withAlert {
                try? await viewModel.themeViewModel.fetchThemes()
            }
        }
        .onOpenURL { url in
            Task {
                try? await viewModel.handleURLScheme(url)
            }
        }
    }
}
