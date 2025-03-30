//
//  ContentViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Combine
import Dependencies
import Foundation
import Timetable
import ConfigsInterface
import Configs

@Observable
@MainActor
class ContentViewModel {
    @ObservationIgnored
    @Dependency(\.timetableRepository) var timetableRepository

    @ObservationIgnored
    @Dependency(\.configsRepository) var configsRepository

    private let authState: any AuthState
    private(set) var isAuthenticated: Bool
    var selectedTab: TabItem = .timetable
    private var cancellables: Set<AnyCancellable> = []

    let timetableRouter: TimetableRouter = .init()
    let lectureSearchRouter: LectureSearchRouter = .init()

    private(set) var configs: ConfigsModel = .empty

    init() {
        authState = Dependency(\.authState).wrappedValue
        isAuthenticated = authState.isAuthenticated
        authState.isAuthenticatedPublisher
            .receive(on: DispatchQueue.main)
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
