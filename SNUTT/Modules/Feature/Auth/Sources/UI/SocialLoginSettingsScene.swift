//
//  SocialLoginSettingsScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AuthInterface
import SwiftUI

public struct SocialLoginSettingsScene: View {
    @State private var viewModel: SocialLoginSettingsViewModel = .init()
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    public init() {}

    public var body: some View {
        Form {
            Section {
                providerRow(
                    provider: .kakao,
                    title: AuthStrings.socialLinkKakao,
                    isLinked: viewModel.socialLoginState?.kakao == .linked,
                    onLink: { try await viewModel.linkSocialProvider(provider: .kakao) },
                    onUnlink: { try await viewModel.unlinkSocialProvider(provider: .kakao) }
                )

                providerRow(
                    provider: .google,
                    title: AuthStrings.socialLinkGoogle,
                    isLinked: viewModel.socialLoginState?.google == .linked,
                    onLink: { try await viewModel.linkSocialProvider(provider: .google) },
                    onUnlink: { try await viewModel.unlinkSocialProvider(provider: .google) }
                )

                providerRow(
                    provider: .apple,
                    title: AuthStrings.socialLinkApple,
                    isLinked: viewModel.socialLoginState?.apple == .linked,
                    onLink: { try await viewModel.linkSocialProvider(provider: .apple) },
                    onUnlink: { try await viewModel.unlinkSocialProvider(provider: .apple) }
                )

                providerRow(
                    provider: .facebook,
                    title: AuthStrings.socialLinkFacebook,
                    isLinked: viewModel.socialLoginState?.facebook == .linked,
                    onLink: { try await viewModel.linkSocialProvider(provider: .facebook) },
                    onUnlink: { try await viewModel.unlinkSocialProvider(provider: .facebook) }
                )
            }
        }
        .navigationTitle(AuthStrings.socialLinkTitle)
    }

    @ViewBuilder
    private func providerRow(
        provider: SocialAuthProvider,
        title: String,
        isLinked: Bool,
        onLink: @escaping () async throws -> Void,
        onUnlink: @escaping () async throws -> Void
    ) -> some View {
        HStack {
            Text(AuthStrings.socialLinkAccount(title))
            Spacer()
            if isLinked {
                Button {
                    errorAlertHandler.withAlert {
                        try await onUnlink()
                    }
                } label: {
                    Text(AuthStrings.socialLinkUnlinkButton)
                        .foregroundColor(.red)
                }
            } else {
                Button {
                    errorAlertHandler.withAlert {
                        try await onLink()
                    }
                } label: {
                    Text(AuthStrings.socialLinkButton)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SocialLoginSettingsScene()
    }
}
