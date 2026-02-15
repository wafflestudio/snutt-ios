//
//  AppleAuthService.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import AuthenticationServices

final class AppleAuthService: NSObject, SocialAuthService {
    @MainActor
    private var continuation: CheckedContinuation<String, any Error>?

    @MainActor
    func authenticate() async throws(SocialAuthError) -> String {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation

                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = [.email, .fullName]

                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = self
                controller.performRequests()
            }
        } catch let error as SocialAuthError {
            throw error
        } catch {
            throw SocialAuthError(provider: .apple, reason: .sdkError(error))
        }
    }
}

extension AppleAuthService: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        Task { @MainActor in
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let identityToken = credential.identityToken,
                let token = String(data: identityToken, encoding: .utf8)
            else {
                continuation?.resume(throwing: SocialAuthError(provider: .apple, reason: .tokenNotFound))
                continuation = nil
                return
            }
            continuation?.resume(returning: token)
            continuation = nil
        }
    }

    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        Task { @MainActor in
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                continuation?.resume(throwing: SocialAuthError(provider: .apple, reason: .cancelled))
            } else {
                continuation?.resume(throwing: SocialAuthError(provider: .apple, reason: .sdkError(error)))
            }
            continuation = nil
        }
    }
}
