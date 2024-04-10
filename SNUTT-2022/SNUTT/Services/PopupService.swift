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
        let localPopupDtos = userDefaultsRepository.get([PopupMetadata].self, key: .popupList, defaultValue: [])
        let mergedPopupDtos = mergePopups(local: localPopupDtos, into: remotePopupDtos)
        appState.popup.currentList = mergedPopupDtos.map {
            var popup = Popup(from: $0)
            if !popup.dontShowForWhile {
                popup.dismissedAt = nil
            }
            return popup
        }
        userDefaultsRepository.set([PopupDto].self, key: .popupList, value: mergedPopupDtos)
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

extension PopupService {
    private func mergePopups(local: [PopupMetadata], into remote: [PopupDto]) -> [PopupDto] {
        let localPopupByKey = Dictionary(grouping: local, by: { $0.key })
        return remote.map { popupDto in
            guard let localPopup = localPopupByKey[popupDto.key]?.first else {
                return popupDto
            }
            if popupDto.hiddenDays != localPopup.hiddenDays {
                return popupDto
            }
            return .init(from: localPopup, imageUri: popupDto.imageUri)
        }
    }
}

class FakePopupService: PopupServiceProtocol {
    func getRecentPopupList() async throws {}
    func dismissPopup(popup _: Popup, dontShowForWhile _: Bool) {}
}
