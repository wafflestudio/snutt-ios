//
//  SettingsDetails.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import NotificationsInterface
import SharedUIComponents
import SwiftUI
import ThemesInterface
import TimetableInterface
import VacancyInterface

#if FEATURE_LECTURE_DIARY
    import LectureDiaryInterface
#endif

struct SettingsDetails: View {
    let menuItem: SettingsPathType
    let viewModel: SettingsViewModel

    @Environment(\.vacancyUIProvider) private var vacancyUIProvider
    @Environment(\.notificationsUIProvider) private var notificationsUIProvider
    @Environment(\.timetableUIProvider) private var timetableUIProvider
    #if FEATURE_LECTURE_DIARY
        @Environment(\.lectureDiaryUIProvider) private var lectureDiaryUIProvider
    #endif
    @Environment(\.themeUIProvider) private var themeUIProvider
    #if DEBUG
        @Environment(\.networkLogUIProvider) private var networkLogUIProvider
    #endif

    var body: some View {
        switch menuItem {
        case .myAccount:
            MyAccountScene(viewModel: viewModel.myAccountViewModel)
                .analyticsScreen(.settingsAccount)
        case .notificationInbox:
            AnyView(notificationsUIProvider.makeNotificationsScene())
        case .appearance:
            ColorModeSettingView()
                .analyticsScreen(.settingsColorScheme)
        case .timetableSettings:
            TimetableSettingView(viewModel: viewModel.timetableSettingsViewModel)
                .analyticsScreen(.settingsTimetable)
        case .timetableRange:
            TimetableRangeSelectionView(viewModel: viewModel.timetableSettingsViewModel)
        case .timetableTheme:
            AnyView(themeUIProvider.themeSettingsScene())
        case .pushNotificationSettings:
            PushNotificationSettingsView(viewModel: viewModel.pushNotificationSettingsViewModel)
                .analyticsScreen(.settingsPushNotification)
        case .vacancyNotification:
            AnyView(vacancyUIProvider.makeVacancyScene())
                .analyticsScreen(.vacancy)
        case .lectureReminder:
            timetableUIProvider.makeLectureReminderScene()
        #if FEATURE_LECTURE_DIARY
            case .lectureDiary:
                lectureDiaryUIProvider.makeLectureDiaryListView()
        #endif
        case .themeMarket:
            AnyView(themeUIProvider.themeMarketScene())
        case .developers:
            DeveloperInfoView()
                .analyticsScreen(.settingsDevelopers)
        case .userSupport:
            UserSupportScene()
                .analyticsScreen(.settingsSupport)
        case .termsOfService:
            TermsOfServiceView()
        case .privacyPolicy:
            PrivacyPolicyView()
        #if DEBUG
            case .networkLogs:
                AnyView(networkLogUIProvider.makeNetworkLogsScene())
        #endif
        }
    }
}
