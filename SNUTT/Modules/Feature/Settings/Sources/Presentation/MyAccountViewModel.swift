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

    // FIXME: load actual user data
    var userNickname: String = "와플#7777"

    func deleteAccount() async throws {
        try await authUseCase.deleteAccount()
    }
}
