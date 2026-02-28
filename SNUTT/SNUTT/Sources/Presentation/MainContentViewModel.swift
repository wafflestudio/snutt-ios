//
//  MainContentViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Combine
import Dependencies
import Foundation
import LectureDiaryInterface
import Observation
import SwiftUtility
import Themes
import ThemesInterface
import Timetable
import TimetableInterface

@Observable
@MainActor
final class MainContentViewModel {
    @ObservationIgnored
    @Dependency(\.timetableUseCase) var timetableUseCase

    @ObservationIgnored
    @Dependency(\.notificationCenter) var notificationCenter

    var selectedTab: TabItem = .timetable
    private var cancellables: Set<AnyCancellable> = []

    var diaryEditContext: DiaryEditContext?

    let themeViewModel: ThemeViewModel
    let timetableViewModel: TimetableViewModel

    init() {
        let timetableViewModel = TimetableViewModel()
        let themeViewModel = ThemeViewModel(saveSelectedTheme: { [weak timetableViewModel] theme in
            guard let currentTimetable = timetableViewModel?.currentTimetable else { return }
            let timetable = try await Dependency(\.timetableUseCase).wrappedValue
                .updateTheme(timetableID: currentTimetable.id, theme: theme)
            try timetableViewModel?.setCurrentTimetable(timetable)
        })

        self.timetableViewModel = timetableViewModel
        self.themeViewModel = themeViewModel

        // Navigation message subscriptions
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

        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToTimetableMessage.self)
        ) { @MainActor viewModel, _ in
            viewModel.selectedTab = .timetable
        }

        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToLectureRemindersMessage.self)
        ) { @MainActor viewModel, _ in
            viewModel.selectedTab = .settings
        }

        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToLectureDiaryMessage.self)
        ) { @MainActor viewModel, _ in
            viewModel.selectedTab = .timetable
        }
    }
}
