//
//  AuthUserState.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Combine
import Dependencies
import DependenciesAdditions
import Foundation

public class AuthUserState: AuthState, @unchecked Sendable {
    @Dependency(\.userDefaults) private var userDefaults
    private var store = [AuthStateType: String]()
    private let lock = NSRecursiveLock()

    public init() {}

    @Published public private(set) var isAuthenticated = false
    public var isAuthenticatedPublisher: AnyPublisher<Bool, Never> {
        $isAuthenticated.eraseToAnyPublisher()
    }

    public func set(_ type: AuthStateType, value: String) {
        lock.sync {
            store[type] = value
            switch type {
            case .userID:
                userDefaults.set(value, forKey: type.rawValue)
            case .accessToken:
                isAuthenticated = true
            }
        }
    }

    public func get(_ type: AuthStateType) -> String? {
        lock.sync {
            switch type {
            case .userID:
                store[type] ?? userDefaults.string(forKey: type.rawValue)
            case .accessToken:
                store[type]
            }
        }
    }

    public func clear() {
        lock.sync {
            store.removeAll()
            userDefaults.removeValue(forKey: AuthStateType.userID.rawValue)
            isAuthenticated = false
        }
    }
}

private extension NSRecursiveLock {
    @discardableResult func sync<R>(work: () throws -> R) rethrows -> R {
        lock()
        defer { self.unlock() }
        return try work()
    }
}
