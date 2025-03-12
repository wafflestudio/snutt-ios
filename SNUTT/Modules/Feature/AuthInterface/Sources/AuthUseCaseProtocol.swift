//
//  AuthUseCaseProtocol.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable

@Spyable
public protocol AuthUseCaseProtocol: Sendable {
    func loginWithLocalID(localID: String, localPassword: String) async throws
    func logout() async throws
    func registerFCMToken(_ token: String) async throws
    func deleteAccount() async throws
}

public enum AuthUseCaseKey: TestDependencyKey {
    public static let testValue: any AuthUseCaseProtocol = AuthUseCaseProtocolSpy()
    public static let previewValue: any AuthUseCaseProtocol = AuthUseCaseProtocolSpy()
}

extension DependencyValues {
    public var authUseCase: any AuthUseCaseProtocol {
        get { self[AuthUseCaseKey.self] }
        set { self[AuthUseCaseKey.self] = newValue }
    }
}
