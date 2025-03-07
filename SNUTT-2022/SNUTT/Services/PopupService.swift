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
            var popup = $0
            return popup.resetDismissedAt()
        }
    }

    func dismissPopup(popup: Popup, dontShowForWhile: Bool) {
        guard let firstPopupIndex = appState.popup.currentList.firstIndex(where: { $0.id == popup.id }) else { return }
        appState.popup.currentList[firstPopupIndex].markAsDismissed(dontShowForWhile: dontShowForWhile)
        let currentPopupMetadataList = appState.popup.currentList.compactMap { PopupMetadata(from: $0) }
        userDefaultsRepository.set([PopupMetadata].self, key: .popupList, value: currentPopupMetadataList)
    }
}

extension PopupService {
    private func mergePopups(local: [PopupMetadata], into remote: [PopupDto]) -> [Popup] {
        let localPopupByKey = Dictionary(grouping: local, by: { $0.key })
        return remote.map { popupDto in
            guard let localPopup = localPopupByKey[popupDto.key]?.first else {
                return .init(from: popupDto)
            }
            if popupDto.hiddenDays != localPopup.hiddenDays {
                return .init(from: popupDto)
            }
            return .init(from: localPopup, imageUri: popupDto.imageUri, linkUrl: popupDto.linkUrl)
        }
    }
}

class FakePopupService: PopupServiceProtocol {
    func getRecentPopupList() async throws {}
    func dismissPopup(popup _: Popup, dontShowForWhile _: Bool) {}
}
