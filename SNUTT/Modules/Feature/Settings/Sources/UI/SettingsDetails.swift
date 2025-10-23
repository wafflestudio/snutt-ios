//
//  SettingsDetails.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import SharedUIComponents
import SwiftUI
import ThemesInterface
import VacancyInterface

struct SettingsDetails: View {
    let menuItem: SettingsPathType
    let viewModel: SettingsViewModel

    @Environment(\.vacancyUIProvider) private var vacancyUIProvider
    @Environment(\.themeUIProvider) private var themeUIProvider
    #if DEBUG
        @Environment(\.networkLogUIProvider) private var networkLogUIProvider
    #endif

    var body: some View {
        switch menuItem {
        case .myAccount:
            MyAccountScene(viewModel: viewModel.myAccountViewModel)
                .analyticsScreen(.settingsAccount)
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
        case .vacancyNotification:
            AnyView(vacancyUIProvider.makeVacancyScene())
                .analyticsScreen(.vacancy)
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
