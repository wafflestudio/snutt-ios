//
//  MyAccountViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import Observation

@MainActor
@Observable
final class MyAccountViewModel {
    @ObservationIgnored
    @Dependency(\.authUseCase) private var authUseCase

    func deleteAccount() async throws {
        try await authUseCase.deleteAccount()
    }
}
