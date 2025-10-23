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
import Themes
import ThemesInterface
import Timetable

@Observable
@MainActor
class ContentViewModel {
    @ObservationIgnored
    @Dependency(\.timetableRepository) var timetableRepository

    @ObservationIgnored
    @Dependency(\.configsRepository) var configsRepository

    @ObservationIgnored
    @Dependency(\.analyticsLogger) var analyticsLogger

    private let authState: any AuthState
    private(set) var isAuthenticated: Bool
    var selectedTab: TabItem = .timetable
    private var cancellables: Set<AnyCancellable> = []

    let timetableRouter: TimetableRouter
    let lectureSearchRouter: LectureSearchRouter = .init()
    let themeViewModel: ThemeViewModel
    let timetableViewModel: TimetableViewModel

    private(set) var configs: ConfigsModel = .empty

    init() {
        let timetableUseCase = Dependency(\.timetableUseCase).wrappedValue
        let timetableRouter = TimetableRouter()
        let timetableViewModel = TimetableViewModel(router: timetableRouter)
        let themeViewModel = ThemeViewModel(saveSelectedTheme: { [weak timetableViewModel] theme in
            guard let currentTimetable = timetableViewModel?.currentTimetable else { return }
            let timetable = try await timetableUseCase.updateTheme(timetableID: currentTimetable.id, theme: theme)
            try timetableViewModel?.setCurrentTimetable(timetable)
        })
        authState = Dependency(\.authState).wrappedValue
        isAuthenticated = authState.isAuthenticated
        self.timetableRouter = timetableRouter
        self.timetableViewModel = timetableViewModel
        self.themeViewModel = themeViewModel
        authState.isAuthenticatedPublisher
            .sink { [weak self] in
                self?.isAuthenticated = $0
            }
            .store(in: &cancellables)
        Task {
            try await loadConfigs()
        }
    }

    private func loadConfigs() async throws {
        configs = try await configsRepository.fetchConfigs()
    }
}
