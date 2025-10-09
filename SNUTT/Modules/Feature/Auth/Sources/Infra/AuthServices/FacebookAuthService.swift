//
//  FacebookAuthService.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AuthInterface
import FacebookLogin
import UIKit

struct FacebookAuthService: SocialAuthService {
    @MainActor
    func authenticate() async throws(SocialAuthError) -> String {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let loginManager = LoginManager()
                loginManager.logIn(
                    configuration: .init(
                        permissions: [Permission.publicProfile.name],
                        tracking: .limited
                    )
                ) { result in
                    switch result {
                    case .success(_, _, let token):
                        if let token = token {
                            continuation.resume(returning: token.tokenString)
                        } else {
                            continuation.resume(
                                throwing: SocialAuthError(provider: .facebook, reason: .tokenNotFound)
                            )
                        }
                    case .cancelled:
                        continuation.resume(
                            throwing: SocialAuthError(provider: .facebook, reason: .cancelled)
                        )
                    case .failed(let error):
                        continuation.resume(throwing: SocialAuthError(provider: .facebook, reason: .sdkError(error)))
                    }
                }
            }
        } catch let error as SocialAuthError {
            throw error
        } catch {
            throw .init(provider: .facebook, reason: .sdkError(error))
        }
    }
}
