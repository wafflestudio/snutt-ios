//
//  PopupAPIRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import OpenAPIURLSession

struct PopupAPIRepository: PopupServerRepository {
    @Dependency(\.apiClient) private var apiClient

    func fetchPopups() async throws -> [ServerPopup] {
        let popups = try await apiClient.getPopups().ok.body.json
        return popups.content.map {
            ServerPopup(
                key: $0.key,
                imageUri: $0.imageUri,
                linkURL: $0.linkUrl.flatMap { URL(string: $0) },
                hiddenDays: $0.hiddenDays.flatMap { Int($0) }
            )
        }
    }
}
