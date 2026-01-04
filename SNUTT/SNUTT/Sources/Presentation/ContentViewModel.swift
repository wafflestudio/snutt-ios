//
//  ContentViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Combine
import Dependencies
import Foundation
import Observation

@Observable
@MainActor
final class ContentViewModel {
    @ObservationIgnored
    @Dependency(\.authState) private var authState

    private var cancellables: Set<AnyCancellable> = []

    var isAuthenticated: Bool = false

    init() {
        isAuthenticated = authState.isAuthenticated
        authState.isAuthenticatedPublisher
            .sink { [weak self] isAuthenticated in
                self?.isAuthenticated = isAuthenticated
            }
            .store(in: &cancellables)
    }
}
