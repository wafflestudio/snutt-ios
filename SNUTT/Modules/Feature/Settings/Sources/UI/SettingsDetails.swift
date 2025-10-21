//
//  SettingsDetails.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import ThemesInterface
import VacancyInterface

struct SettingsDetails: View {
    let menuItem: SettingsPathType
    let viewModel: SettingsViewModel

    @Environment(\.vacancyUIProvider) private var vacancyUIProvider
    @Environment(\.themeUIProvider) private var themeUIProvider

    var body: some View {
        switch menuItem {
        case .myAccount:
            MyAccountScene(viewModel: viewModel.myAccountViewModel)
        case .appearance:
            ColorModeSettingView()
        case .timetableSettings:
            TimetableSettingView(viewModel: viewModel.timetableSettingsViewModel)
        case .timetableRange:
            TimetableRangeSelectionView(viewModel: viewModel.timetableSettingsViewModel)
        case .timetableTheme:
            AnyView(themeUIProvider.themeSettingsScene())
        case .vacancyNotification:
            AnyView(vacancyUIProvider.makeVacancyScene())
        case .themeMarket:
            AnyView(themeUIProvider.themeMarketScene())
        case .developers:
            DeveloperInfoView()
        case .shareFeedback:
            ColorView(color: .cyan)
        case .termsOfService:
            TermsOfServiceView()
        case .privacyPolicy:
            PrivacyPolicyView()
        case .networkLogs:
            ColorView(color: .red)
        }
    }
}
