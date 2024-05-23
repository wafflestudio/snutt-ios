
//
//  AuthUseCase.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import AuthInterface

struct AuthUseCase {
    @Dependency(\.authRepository) private var authRepository
    @Dependency(\.authState) private var authState
    @Dependency(\.authSecureRepository) private var secureRepository

    func loginWithLocalID(localID: String, localPassword: String) async throws {
        let response = try await authRepository.loginWithLocalID(localID: localID, localPassword: localPassword)
        try secureRepository.saveAccessToken(response.accessToken)
        authState.set(.accessToken, value: response.accessToken)
        authState.set(.userID, value: response.userID)
    }
}

extension AuthUseCase: DependencyKey {
    static let liveValue: AuthUseCase = AuthUseCase()
}

extension DependencyValues {
    var authUseCase: AuthUseCase {
        get { self[AuthUseCase.self] }
        set { self[AuthUseCase.self] = newValue }
    }
}
