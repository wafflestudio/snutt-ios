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
    func addDevice(fcmToken: String) async throws
    func registerWithLocalID(localID: String, localPassword: String, email: String) async throws -> LoginResponse
    func loginWithLocalID(localID: String, localPassword: String) async throws -> LoginResponse
//    func loginWithApple(appleToken: String) async throws -> LoginResponseDto
//    func loginWithFacebook(fbId: String, fbToken: String) async throws -> LoginResponseDto
//    func findLocalId(email: String) async throws -> SendLocalIdDto
//    func getLinkedEmail(localId: String) async throws -> LinkedEmailDto
//    func sendVerificationCode(email: String) async throws
//    func checkVerificationCode(localId: String, code: String) async throws
//    func resetPassword(localId: String, password: String) async throws
    func logout(fcmToken: String) async throws
    func deleteAccount() async throws
}

@MemberwiseInit(.public)
public struct LoginResponse: Sendable {
    public let accessToken: String
    /// Server-side id of user entity
    public let userID: String
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
