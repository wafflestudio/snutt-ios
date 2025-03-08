//
//  AuthUseCase.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable

@Spyable
public protocol AuthUseCase: Sendable {
    func loginWithLocalID(localID: String, localPassword: String) async throws
    func logout() async throws
    func registerFCMToken(_ token: String) async throws
    func deleteAccount() async throws
}

public enum AuthUseCaseKey:
    TestDependencyKey
{
    public static let testValue: any AuthUseCase = AuthUseCaseSpy()
    public static let previewValue: any AuthUseCase = AuthUseCaseSpy()
}

extension DependencyValues {
    public var authUseCase: any AuthUseCase {
        get { self[AuthUseCaseKey.self] }
        set { self[AuthUseCaseKey.self] = newValue }
    }
}
