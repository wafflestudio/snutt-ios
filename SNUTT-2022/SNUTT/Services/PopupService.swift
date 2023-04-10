//
//  PopupService.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/04.
//

import Foundation
import SwiftUI

@MainActor
protocol PopupServiceProtocol: Sendable {
    func getRecentPopupList() async throws
    func dismissPopup(popup: Popup, dontShowForWhile: Bool)
}

struct PopupService: PopupServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories
    var localRepositories: AppEnvironment.LocalRepositories

    var userDefaultsRepository: UserDefaultsRepositoryProtocol {
        localRepositories.userDefaultsRepository
    }

    var popupRepository: PopupRepositoryProtocol {
        webRepositories.popupRepository
    }

    func getRecentPopupList() async throws {
        let remotePopupDtos = try await popupRepository.getRecentPopupList()
        let localPopupDtos = userDefaultsRepository.get([PopupDto].self, key: .popupList, defaultValue: [])
        let concatPopupDtos = (localPopupDtos + remotePopupDtos).map { ($0.key, Popup(from: $0)) }
        let popupDictByKey = Dictionary(concatPopupDtos, uniquingKeysWith: { key, _ in key })

        appState.popup.currentList = popupDictByKey.values.map {
            var popup = $0
            if !popup.dontShowForWhile {
                popup.dismissedAt = nil
            }
            return popup
        }
    }

    func dismissPopup(popup: Popup, dontShowForWhile: Bool) {
        var currentPopupList = appState.popup.currentList
        guard let firstPopupIndex = currentPopupList.firstIndex(where: { $0.id == popup.id }) else { return }
        currentPopupList[firstPopupIndex].dismissedAt = Date()
        currentPopupList[firstPopupIndex].dontShowForWhile = dontShowForWhile
        appState.popup.currentList = currentPopupList
        let currentPopupListDto = currentPopupList.compactMap { PopupDto(from: $0) }
        userDefaultsRepository.set([PopupDto].self, key: .popupList, value: currentPopupListDto)
    }
}

class FakePopupService: PopupServiceProtocol {
    func getRecentPopupList() async throws {}
    func dismissPopup(popup _: Popup, dontShowForWhile _: Bool) {}
}
