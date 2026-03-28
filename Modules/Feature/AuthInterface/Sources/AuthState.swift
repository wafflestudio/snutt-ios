//
//  AuthState.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Combine
import Dependencies
import Foundation
import Spyable

@Spyable
public protocol AuthState: Sendable, AnyObject {
    var isAuthenticated: Bool { get }
    @MainActor var isAuthenticatedPublisher: AnyPublisher<Bool, Never> { get }
    func set(_ type: AuthStateType, value: String)
    func get(_ type: AuthStateType) -> String?
    func clear()
}

public enum AuthStateType: String, Sendable {
    case userID, accessToken, fcmToken
}

public enum AuthStateKey: TestDependencyKey {
    public static let testValue: any AuthState = {
        let spy = AuthStateSpy()
        let subject = CurrentValueSubject<Bool, Never>(false)
        spy.underlyingIsAuthenticated = false
        spy.setValueClosure = { [weak spy] _, _ in
            spy?.underlyingIsAuthenticated = true
            subject.value = true
        }
        spy.underlyingIsAuthenticatedPublisher = subject.eraseToAnyPublisher()
        return spy
    }()

    public static let previewValue: any AuthState = {
        let spy = AuthStateSpy()
        let subject = CurrentValueSubject<Bool, Never>(false)
        spy.underlyingIsAuthenticated = false
        spy.setValueClosure = { [weak spy] _, _ in
            spy?.underlyingIsAuthenticated = true
            subject.value = true
        }
        spy.underlyingIsAuthenticatedPublisher = subject.eraseToAnyPublisher()
        return spy
    }()
}

extension DependencyValues {
    public var authState: any AuthState {
        get { self[AuthStateKey.self] }
        set { self[AuthStateKey.self] = newValue }
    }
}
