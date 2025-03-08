
//
//  AuthUseCase.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies

public struct AuthMainUseCase: AuthUseCase {
    @Dependency(\.authRepository) private var authRepository
    @Dependency(\.authState) private var authState
    @Dependency(\.authSecureRepository) private var secureRepository
    
    public init() {}

    public func loginWithLocalID(localID: String, localPassword: String) async throws {
        let response = try await authRepository.loginWithLocalID(localID: localID, localPassword: localPassword)
        try secureRepository.saveAccessToken(response.accessToken)
        authState.set(.accessToken, value: response.accessToken)
        authState.set(.userID, value: response.userID)
    }
    
    public func logout() async throws {
        guard let fcmToken = authState.get(.fcmToken) else {
            return
        }
        try await authRepository.logout(fcmToken: fcmToken)
        authState.clear()
    }
    
    public func addDevice(fcmToken: String) async throws {
        try await authRepository.addDevice(fcmToken: fcmToken)
        authState.set(.fcmToken, value: fcmToken)
    }
}
