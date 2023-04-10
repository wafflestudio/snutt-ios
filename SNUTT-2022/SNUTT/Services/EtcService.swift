//
//  EtcService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/07.
//

import Foundation
import SwiftUI

@MainActor
protocol EtcServiceProtocol {
    func sendFeedback(email: String, message: String) async throws
}

struct EtcService: EtcServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    private var etcRepository: EtcRepositoryProtocol {
        return webRepositories.etcRepository
    }

    func sendFeedback(email: String, message: String) async throws {
        try await etcRepository.sendFeedback(email: email, message: message)
    }
}

class FakeEtcService: EtcServiceProtocol {
    func sendFeedback(email _: String, message _: String) async throws {}
}
