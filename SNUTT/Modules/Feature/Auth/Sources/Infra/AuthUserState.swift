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
import DependenciesUtility
import Foundation
import os

public final class AuthUserState: AuthState {
    private let userDefaultsDep = Dependency(\DependencyValues.userDefaults)
    private var userDefaults: UserDefaults.Dependency {
        userDefaultsDep.wrappedValue
    }

    public init() {}

    private let store = OSAllocatedUnfairLock(uncheckedState: [AuthStateType: String]())
    public var isAuthenticated: Bool {
        isAuthenticatedLocked.withLock { $0 }
    }

    private let isAuthenticatedLocked = OSAllocatedUnfairLock(initialState: false)
    @MainActor private let isAuthenticatedSubject = PassthroughSubject<Bool, Never>()
    @MainActor public var isAuthenticatedPublisher: AnyPublisher<Bool, Never> {
        isAuthenticatedSubject.eraseToAnyPublisher()
    }

    public func set(_ type: AuthStateType, value: String) {
        store.withLock { $0[type] = value }
        switch type {
        case .userID:
            userDefaults[\.userID] = value
        case .accessToken:
            try? Dependency(\.authSecureRepository).wrappedValue.saveAccessToken(value)
            isAuthenticatedLocked.withLock { $0 = true }
            Task { @MainActor in
                isAuthenticatedSubject.send(true)
            }
        case .fcmToken:
            userDefaults[\.fcmToken] = value
        }
    }

    public func get(_ type: AuthStateType) -> String? {
        switch type {
        case .userID:
            store.withLock { $0[.userID] } ?? userDefaults[\.userID]
        case .accessToken:
            store.withLock { $0[.accessToken] }
        case .fcmToken:
            store.withLock { $0[.fcmToken] } ?? userDefaults[\.fcmToken]
        }
    }

    public func clear() {
        store.withLock { $0.removeAll() }
        userDefaults[\.userID] = nil
        isAuthenticatedLocked.withLock { $0 = false }
        Task { @MainActor in
            isAuthenticatedSubject.send(false)
        }
    }
}

extension UserDefaultsEntryDefinitions {
    var userID: UserDefaultsEntry<String?> {
        .init(key: "userID", defaultValue: nil)
    }

    var fcmToken: UserDefaultsEntry<String?> {
        .init(key: "fcmToken", defaultValue: nil)
    }
}
