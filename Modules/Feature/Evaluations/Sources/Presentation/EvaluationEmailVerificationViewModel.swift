//
//  EvaluationEmailVerificationViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import AnalyticsInterface
import AuthInterface
import Dependencies
import Foundation
import Observation

/// The evaluation server rejects users without a verified SNU email, so they verify one before seeing evaluations.
@MainActor
@Observable
final class EvaluationEmailVerificationViewModel {
    enum Status: Equatable {
        case checking
        case unverified
        case verified
    }

    static let emailDomain = "@snu.ac.kr"
    static let codeLength = 6
    /// How long the server accepts a code after sending it.
    static let codeLifetime: TimeInterval = 180

    private(set) var status: Status = .checking
    var emailID = ""
    var code = ""
    /// The address the latest code was sent to, or `nil` before one is requested.
    private(set) var codeRecipient: String?
    private(set) var codeExpiration: Date?
    private(set) var isRequestingCode = false
    private(set) var isVerifying = false
    /// Set when the email is already verified by another account, which the user can only resolve elsewhere.
    private(set) var isEmailInUse = false

    @ObservationIgnored
    @Dependency(\.authRepository) private var authRepository

    @ObservationIgnored
    @Dependency(\.analyticsLogger) private var analyticsLogger

    @ObservationIgnored
    @Dependency(\.date) private var date

    var canRequestCode: Bool {
        !emailID.trimmingCharacters(in: .whitespaces).isEmpty && !isRequestingCode
    }

    func canVerify(at now: Date) -> Bool {
        code.count == Self.codeLength && !isCodeExpired(at: now) && !isVerifying
    }

    func isCodeExpired(at now: Date) -> Bool {
        codeExpiration.map { now >= $0 } ?? false
    }

    func remainingCodeTime(at now: Date) -> TimeInterval {
        codeExpiration.map { max(0, $0.timeIntervalSince(now)) } ?? 0
    }

    func checkStatus() async {
        // A failed check falls through to the evaluations, whose own loading reports the error and can be retried.
        let isVerified = try? await authRepository.fetchIsEmailVerified()
        status = isVerified == false ? .unverified : .verified
    }

    func requestCode() async throws {
        // Views call this from a new task, so a second tap can arrive before the first call marks itself in flight.
        guard canRequestCode else { return }
        let email = emailID.trimmingCharacters(in: .whitespaces) + Self.emailDomain
        isRequestingCode = true
        defer { isRequestingCode = false }
        isEmailInUse = false
        do {
            try await authRepository.sendVerificationCode(email: email)
        } catch {
            if case .predefined(.duplicateEmail) = error.apiClientError {
                isEmailInUse = true
            }
            throw error
        }
        code = ""
        codeRecipient = email
        codeExpiration = date.now.addingTimeInterval(Self.codeLifetime)
    }

    func verify() async throws {
        guard !isVerifying else { return }
        isVerifying = true
        defer { isVerifying = false }
        try await authRepository.confirmEmailVerification(code: code)
        analyticsLogger.logEvent(AnalyticsAction.verifyEmail)
        status = .verified
    }
}
