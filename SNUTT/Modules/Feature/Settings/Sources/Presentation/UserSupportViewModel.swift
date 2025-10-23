//
//  UserSupportViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import Foundation
import Observation

@MainActor
@Observable
final class UserSupportViewModel {
    @ObservationIgnored
    @Dependency(\.settingsRepository) private var settingsRepository

    @ObservationIgnored
    @Dependency(\.authRepository) private var authRepository

    var email: String = ""
    var content: String = ""
    var hasEmail: Bool = false
    var isLoading: Bool = false
    var showSendConfirmation: Bool = false
    var showSuccessMessage: Bool = false

    init() {
        Task {
            await loadUserEmail()
        }
    }

    var isButtonDisabled: Bool {
        email.isEmpty || content.isEmpty
    }

    private func loadUserEmail() async {
        do {
            let user = try await authRepository.fetchUser()
            if let userEmail = user.email, !userEmail.isEmpty {
                email = userEmail
                hasEmail = true
            }
        } catch {
            // Failed to load user email, let user input manually
            hasEmail = false
        }
    }

    func sendFeedback() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            try await settingsRepository.postFeedback(email: email, message: content)
            showSuccessMessage = true
            return true
        } catch {
            // Error will be shown via error handling
            return false
        }
    }
}
