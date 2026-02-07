//
//  AuthAPIRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import AuthInterface
import Dependencies

public struct AuthAPIRepository: AuthRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func fetchUser() async throws -> User {
        let result = try await apiClient.getUserMe()
        let json = try result.ok.body.json
        return .init(dto: json)
    }

    public func changeNickname(to nickname: String) async throws -> User {
        let result = try await apiClient.patchUserInfo(.init(headers: .init(), body: .json(.init(nickname: nickname))))
        let json = try result.ok.body.json
        return .init(dto: json)
    }

    public func changePassword(oldPassword: String, newPassword: String) async throws -> TokenResponse {
        let result = try await apiClient.changePassword(
            body: .json(.init(new_password: newPassword, old_password: oldPassword))
        )
        let json = try result.ok.body.json
        return .init(accessToken: json.token)
    }

    public func registerWithLocalID(
        localID: String,
        localPassword: String,
        email: String
    ) async throws -> LoginResponse {
        let result = try await apiClient.registerLocal(
            body: .json(.init(email: email, id: localID, password: localPassword))
        )
        let json = try result.ok.body.json
        return .init(accessToken: json.token, userID: json.user_id)
    }

    public func loginWithLocalID(localID: String, localPassword: String) async throws -> LoginResponse {
        let result = try await apiClient.loginLocal(body: .json(.init(id: localID, password: localPassword)))
        let json = try result.ok.body.json
        return .init(accessToken: json.token, userID: json.user_id)
    }

    public func loginWithSocial(provider: SocialAuthProvider, providerToken: String) async throws -> LoginResponse {
        let result =
            switch provider {
            case .kakao: try await apiClient.loginKakao(body: .json(.init(token: providerToken))).ok.body.json
            case .google: try await apiClient.loginGoogle(body: .json(.init(token: providerToken))).ok.body.json
            case .apple: try await apiClient.loginApple(body: .json(.init(token: providerToken))).ok.body.json
            case .facebook: try await apiClient.loginFacebook(body: .json(.init(token: providerToken))).ok.body.json
            }
        return .init(accessToken: result.token, userID: result.user_id)
    }

    public func linkSocial(provider: SocialAuthProvider, providerToken: String) async throws -> TokenResponse {
        let result =
            switch provider {
            case .kakao: try await apiClient.attachKakao(body: .json(.init(token: providerToken))).ok.body.json
            case .google: try await apiClient.attachGoogle(body: .json(.init(token: providerToken))).ok.body.json
            case .apple: try await apiClient.attachApple(body: .json(.init(token: providerToken))).ok.body.json
            case .facebook: try await apiClient.attachFacebook(body: .json(.init(token: providerToken))).ok.body.json
            }
        return .init(accessToken: result.token)
    }

    public func unlinkSocial(provider: SocialAuthProvider) async throws -> TokenResponse {
        let result =
            switch provider {
            case .kakao: try await apiClient.detachKakao().ok.body.json
            case .google: try await apiClient.detachGoogle().ok.body.json
            case .apple: try await apiClient.detachApple().ok.body.json
            case .facebook: try await apiClient.detachFacebook().ok.body.json
            }
        return .init(accessToken: result.token)
    }

    public func attachLocalID(localID: String, localPassword: String) async throws -> TokenResponse {
        let result = try await apiClient.attachLocal(body: .json(.init(id: localID, password: localPassword)))
        let json = try result.ok.body.json
        return .init(accessToken: json.token)
    }

    public func addDevice(fcmToken: String) async throws {
        _ = try await apiClient.addRegistrationId(path: .init(id: fcmToken))
    }

    public func logout(fcmToken: String) async throws {
        _ = try await apiClient.logout(body: .json(.init(registration_id: fcmToken)))
    }

    public func deleteAccount() async throws {
        _ = try await apiClient.deleteAccount()
    }

    public func fetchSocialAuthProviderState() async throws -> SocialAuthProviderState {
        let result = try await apiClient.checkAuthProviders()
        let json: Components.Schemas.AuthProvidersCheckDto = try result.ok.body.json
        return .init(
            apple: json.apple ? .linked : .unlinked,
            facebook: json.facebook ? .linked : .unlinked,
            google: json.google ? .linked : .unlinked,
            kakao: json.kakao ? .linked : .unlinked,
            local: json.local ? .linked : .unlinked
        )
    }
}

// MARK: Password Reset & ID Recovery

extension AuthAPIRepository {
    public func getLinkedEmail(localID: String) async throws -> String {
        let result = try await apiClient.getMaskedEmail(body: .json(.init(user_id: localID)))
        let json = try result.ok.body.json
        return json.email
    }

    public func sendVerificationCode(email: String) async throws {
        let result = try await apiClient.sendVerificationEmail(body: .json(.init(email: email)))
        _ = try result.ok.body.json
    }

    public func sendResetPasswordCode(email: String) async throws {
        let result = try await apiClient.sendResetPasswordCode(body: .json(.init(email: email)))
        _ = try result.ok.body.json
    }

    public func checkVerificationCode(localID: String, code: String) async throws {
        let result = try await apiClient.verifyResetPasswordCode(
            body: .json(.init(code: code, user_id: localID))
        )
        _ = try result.ok.body.json
    }

    public func resetPassword(localID: String, password: String, code: String) async throws {
        let result = try await apiClient.resetPassword(
            body: .json(.init(code: code, password: password, user_id: localID))
        )
        _ = try result.ok.body.json
    }

    public func findLocalID(email: String) async throws {
        let result = try await apiClient.findId(body: .json(.init(email: email)))
        _ = try result.ok.body.json
    }
}

// MARK: Feedback

extension AuthAPIRepository {
    public func sendFeedback(email: String?, message: String) async throws {
        let result = try await apiClient.postFeedback(body: .json(.init(email: email ?? "", message: message)))
        _ = try result.ok.body.json
    }
}
