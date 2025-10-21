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

    @ObservationIgnored
    @Dependency(\.authRepository) private var authRepository

    @ObservationIgnored
    @Dependency(\.authState) private var authState

    private(set) var loadState: UserLoadState = .loading

    init() {
        Task {
            try? await fetchUser()
        }
    }

    var titleDescription: String {
        switch loadState {
        case .loaded(let user):
            user.nickname.description
        case .loading:
            "-"
        }
    }

    private func fetchUser() async throws {
        let user = try await authRepository.fetchUser()
        loadState = .loaded(user)
    }

    func changeNickname(to nickname: String) async throws {
        let user = try await authRepository.changeNickname(to: nickname)
        loadState = .loaded(user)
    }

    func deleteAccount() async throws {
        try await authUseCase.deleteAccount()
    }

    func logout() async throws {
        try await authUseCase.logout()
    }

    func attachLocalID(localID: String, localPassword: String) async throws {
        let snuttToken = try await authRepository.attachLocalID(localID: localID, localPassword: localPassword)
        authState.set(.accessToken, value: snuttToken.accessToken)
        try await fetchUser()
    }

    func changePassword(oldPassword: String, newPassword: String) async throws {
        _ = try await authRepository.changePassword(oldPassword: oldPassword, newPassword: newPassword)
    }
}

extension MyAccountViewModel {
    enum UserLoadState: Sendable {
        case loaded(User)
        case loading
    }
}
