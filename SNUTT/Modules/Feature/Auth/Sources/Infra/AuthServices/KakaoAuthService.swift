//
//  KakaoAuthService.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Foundation
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

struct KakaoAuthService: SocialAuthService {
    @MainActor
    func authenticate() async throws(SocialAuthError) -> String {
        do {
            if UserApi.isKakaoTalkLoginAvailable() {
                return try await withCheckedThrowingContinuation { continuation in
                    UserApi.shared.loginWithKakaoTalk { token, error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else if let token = token?.accessToken {
                            continuation.resume(returning: token)
                        } else {
                            continuation.resume(throwing: SocialAuthError(provider: .kakao, reason: .tokenNotFound))
                        }
                    }
                }
            } else {
                return try await withCheckedThrowingContinuation { continuation in
                    UserApi.shared.loginWithKakaoAccount { token, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let token = token?.accessToken {
                            continuation.resume(returning: token)
                        } else {
                            continuation.resume(throwing: SocialAuthError(provider: .kakao, reason: .tokenNotFound))
                        }
                    }
                }
            }
        } catch let error as SocialAuthError {
            throw error
        } catch let sdkError as SdkError {
            if case .ClientFailed(let reason, _) = sdkError, reason == .Cancelled {
                throw .init(provider: .kakao, reason: .cancelled)
            }
            throw .init(provider: .kakao, reason: .sdkError(sdkError))
        } catch {
            throw .init(provider: .kakao, reason: .sdkError(error))
        }
    }
}
