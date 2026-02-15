//
//  AuthSecureRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
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

extension DependencyValues {
    public var authSecureRepository: any AuthSecureRepository {
        get { self[AuthSecureRepositoryKey.self] }
        set { self[AuthSecureRepositoryKey.self] = newValue }
    }
}
