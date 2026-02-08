//
//  GoogleAuthService.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AuthInterface
import GoogleSignIn
import UIKit

struct GoogleAuthService: SocialAuthService {
    @MainActor
    func authenticate() async throws(SocialAuthError) -> String {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootViewController = windowScene.windows.first?.rootViewController
        else {
            throw .init(provider: .google, reason: .invalidWindow)
        }
        do {
            return try await withCheckedThrowingContinuation { continuation in
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                    switch error {
                    case let gidError as GIDSignInError where gidError.code == .canceled:
                        continuation.resume(throwing: SocialAuthError(provider: .google, reason: .cancelled))
                    case .some(let error):
                        continuation.resume(throwing: SocialAuthError(provider: .google, reason: .sdkError(error)))
                    case .none:
                        if let accessToken = result?.user.accessToken.tokenString {
                            continuation.resume(returning: accessToken)
                        } else {
                            continuation.resume(throwing: SocialAuthError(provider: .google, reason: .tokenNotFound))
                        }
                    }
                }
            }
        } catch let error as SocialAuthError {
            throw error
        } catch {
            throw .init(provider: .google, reason: .sdkError(error))
        }
    }
}
