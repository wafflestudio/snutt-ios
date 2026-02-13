//
//  AuthUIProvidable.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import SwiftUI

@MainActor
public protocol AuthUIProvidable: Sendable {
    func socialLoginSettingsScene() -> AnyView
    func attachLocalIDScene(
        onAttach: @escaping (String, String) async throws -> Void
    ) -> AnyView
    func changePasswordScene(
        onChangePassword: @escaping (String, String) async throws -> Void
    ) -> AnyView
}

private struct EmptyAuthUIProvider: AuthUIProvidable {
    func socialLoginSettingsScene() -> AnyView {
        AnyView(Text("Empty AuthUIProvider"))
    }

    func attachLocalIDScene(onAttach: @escaping (String, String) async throws -> Void) -> AnyView {
        AnyView(Text("Empty AuthUIProvider"))
    }

    func changePasswordScene(onChangePassword: @escaping (String, String) async throws -> Void) -> AnyView {
        AnyView(Text("Empty AuthUIProvider"))
    }
}

public enum AuthUIProviderKey: TestDependencyKey {
    public static let testValue: any AuthUIProvidable = EmptyAuthUIProvider()
}

extension DependencyValues {
    public var authUIProvider: any AuthUIProvidable {
        get { self[AuthUIProviderKey.self] }
        set { self[AuthUIProviderKey.self] = newValue }
    }
}

extension EnvironmentValues {
    public var authUIProvider: any AuthUIProvidable {
        withDependencies {
            $0.context = .live
        } operation: {
            Dependency(\.authUIProvider).wrappedValue
        }
    }
}
