//
//  ContentViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Combine
import ConfigsInterface
import Dependencies
import Foundation
import Observation

@Observable
@MainActor
final class ContentViewModel {
    @ObservationIgnored
    @Dependency(\.authState) private var authState

    @ObservationIgnored
    @Dependency(\.configsRepository) var configsRepository

    @ObservationIgnored
    @Dependency(\.analyticsLogger) var analyticsLogger

    @ObservationIgnored
    @Dependency(\.notificationCenter) var notificationCenter

    var selectedTab: TabItem = .timetable

    private var cancellables: Set<AnyCancellable> = []

    var isAuthenticated: Bool = false

    private(set) var configs: ConfigsModel = .empty

    init() {
        isAuthenticated = authState.isAuthenticated
        authState.isAuthenticatedPublisher
            .sink { [weak self] isAuthenticated in
                self?.isAuthenticated = isAuthenticated
            }
            .store(in: &cancellables)
    }

    func loadConfigs() async throws {
        configs = try await configsRepository.fetchConfigs()
    }
}
