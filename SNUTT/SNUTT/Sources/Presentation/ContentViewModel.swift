//
//  ContentViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Combine
import Configs
import ConfigsInterface
import Dependencies
import Foundation
import SwiftUtility
import Themes
import ThemesInterface
import Timetable
import TimetableInterface

@Observable
@MainActor
class ContentViewModel {
    @ObservationIgnored
    @Dependency(\.timetableRepository) var timetableRepository

    @ObservationIgnored
    @Dependency(\.configsRepository) var configsRepository

    @ObservationIgnored
    @Dependency(\.analyticsLogger) var analyticsLogger

    @ObservationIgnored
    @Dependency(\.notificationCenter) var notificationCenter

    private let authState: any AuthState
    private(set) var isAuthenticated: Bool
    var selectedTab: TabItem = .timetable
    private var cancellables: Set<AnyCancellable> = []

    let themeViewModel: ThemeViewModel
    let timetableViewModel: TimetableViewModel

    private(set) var configs: ConfigsModel = .empty

    init() {
        let timetableUseCase = Dependency(\.timetableUseCase).wrappedValue
        let timetableViewModel = TimetableViewModel()
        let themeViewModel = ThemeViewModel(saveSelectedTheme: { [weak timetableViewModel] theme in
            guard let currentTimetable = timetableViewModel?.currentTimetable else { return }
            let timetable = try await timetableUseCase.updateTheme(timetableID: currentTimetable.id, theme: theme)
            try timetableViewModel?.setCurrentTimetable(timetable)
        })
        authState = Dependency(\.authState).wrappedValue
        isAuthenticated = authState.isAuthenticated
        self.timetableViewModel = timetableViewModel
        self.themeViewModel = themeViewModel
        authState.isAuthenticatedPublisher
            .sink { [weak self] in self?.isAuthenticated = $0 }
            .store(in: &cancellables)
        Task {
            try await loadConfigs()
        }
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToVacancyMessage.self)
        ) { @MainActor viewModel, _ in
            viewModel.selectedTab = .settings
        }
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToBookmarkMessage.self)
        ) { @MainActor viewModel, _ in
            viewModel.selectedTab = .search
        }
    }

    private func loadConfigs() async throws {
        configs = try await configsRepository.fetchConfigs()
    }
}
