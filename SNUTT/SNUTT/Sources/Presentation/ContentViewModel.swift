//
//  ContentViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AppReviewPromptInterface
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

    private let authState: any AuthState
    private(set) var isAuthenticated: Bool
    var selectedTab: TabItem = .timetable
    var showDiaryEditScene: Bool = true
    //    var showDiaryEditScene: Bool = false
    var diaryLectureID: String = "68ef8d2912cd9c927b32a36c"
    var diaryLectureTitle: String = "디자인 스튜디오"
    private var cancellables: Set<AnyCancellable> = []

    var isAuthenticated: Bool = false

    @ObservationIgnored
    @Dependency(\.configsRepository) private var configsRepository
    @ObservationIgnored
    @Dependency(\.appReviewService) private var appReviewService
    private(set) var configs: ConfigsModel = .empty

    init() {
        appReviewService.recordAppLaunch()
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
