//
//  AuthSecureRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable

@Spyable
public protocol AuthSecureRepository: Sendable {
    func clear() throws
    func saveAccessToken(_ token: String) throws
    func getAccessToken() -> String?
}

public enum AuthEncryptError: Error {
    case encryptFailed
    case deleteFailed
}

public enum AuthSecureRepositoryKey: TestDependencyKey {
    public static let testValue: any AuthSecureRepository = AuthSecureRepositorySpy()
}

public extension DependencyValues {
    var authSecureRepository: any AuthSecureRepository {
        get { self[AuthSecureRepositoryKey.self] }
        set { self[AuthSecureRepositoryKey.self] = newValue }
    }
}
