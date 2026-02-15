//
//  AuthUIProvider.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import SwiftUI

public struct AuthUIProvider: AuthUIProvidable {
    public nonisolated init() {}

    public func socialLoginSettingsScene() -> AnyView {
        AnyView(SocialLoginSettingsScene())
    }

    public func attachLocalIDScene(
        onAttach: @escaping (String, String) async throws -> Void
    ) -> AnyView {
        AnyView(AttachLocalIDScene(onAttach: onAttach))
    }

    public func changePasswordScene(
        onChangePassword: @escaping (String, String) async throws -> Void
    ) -> AnyView {
        AnyView(ChangePasswordScene(onChangePassword: onChangePassword))
    }
}
