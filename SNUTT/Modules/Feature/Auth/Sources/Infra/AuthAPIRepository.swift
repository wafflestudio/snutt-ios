//
//  AuthAPIRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import APIClientInterface

public struct AuthAPIRepository: AuthRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func registerWithLocalID(localID: String, localPassword: String, email: String) async throws -> LoginResponse {
        let result = try await apiClient.loginLocal(body: .json(.init(id: localID, password: localPassword)))
        let json = try result.ok.body.json
        return .init(accessToken: json.token, userID: json.user_id)
    }

    public func loginWithLocalID(localID: String, localPassword: String) async throws -> LoginResponse {
        let result = try await apiClient.loginLocal(body: .json(.init(id: localID, password: localPassword)))
        let json = try result.ok.body.json
        return .init(accessToken: json.token, userID: json.user_id)
    }
}
