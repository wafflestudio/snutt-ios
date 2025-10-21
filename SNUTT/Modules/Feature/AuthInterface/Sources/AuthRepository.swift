//
//  AuthRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import MemberwiseInit
import Spyable

@Spyable
public protocol AuthRepository: Sendable {
    func fetchUser() async throws -> User
    func addDevice(fcmToken: String) async throws
    func registerWithLocalID(localID: String, localPassword: String, email: String) async throws -> LoginResponse
    func loginWithLocalID(localID: String, localPassword: String) async throws -> LoginResponse
    func loginWithSocial(provider: SocialAuthProvider, providerToken: String) async throws -> LoginResponse
    func linkSocial(provider: SocialAuthProvider, providerToken: String) async throws -> TokenResponse
    func unlinkSocial(provider: SocialAuthProvider) async throws -> TokenResponse
    func attachLocalID(localID: String, localPassword: String) async throws -> TokenResponse
    func changePassword(oldPassword: String, newPassword: String) async throws -> TokenResponse
    func changeNickname(to nickname: String) async throws -> User
    func logout(fcmToken: String) async throws
    func deleteAccount() async throws
    func fetchSocialAuthProviderState() async throws -> SocialAuthProviderState

    // Password reset & ID recovery
    func getLinkedEmail(localID: String) async throws -> String
    func sendVerificationCode(email: String) async throws
    func checkVerificationCode(localID: String, code: String) async throws
    func resetPassword(localID: String, password: String, code: String) async throws
    func findLocalID(email: String) async throws

    // Feedback
    func sendFeedback(email: String?, message: String) async throws
}

@MemberwiseInit(.public)
public struct LoginResponse: Sendable {
    public let accessToken: String
    /// Server-side id of user entity
    public let userID: String
}

@MemberwiseInit(.public)
public struct TokenResponse: Sendable {
    public let accessToken: String
}

public enum AuthRepositoryKey: TestDependencyKey {
    public static let testValue: any AuthRepository = {
        let spy = AuthRepositorySpy()
        spy.loginWithLocalIDLocalIDLocalPasswordReturnValue = .init(accessToken: "123", userID: "123")
        return spy
    }()
}

extension DependencyValues {
    public var authRepository: any AuthRepository {
        get { self[AuthRepositoryKey.self] }
        set { self[AuthRepositoryKey.self] = newValue }
    }
}
