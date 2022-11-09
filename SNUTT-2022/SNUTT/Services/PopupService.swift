//
//  PopupService.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/04.
//

import Foundation
import SwiftUI

protocol PopupServiceProtocol {
    func getRecentPopupList() async throws
    func saveLastUpdate(popup: Popup)
    func showNextPopup()
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
        let recentPopupDto = try await popupRepository.getRecentPopupList()
        let savedPopupDto = userDefaultsRepository.get([PopupDto].self, key: .popupList, defaultValue: [])
        var recentPopupList = recentPopupDto.compactMap { Popup(from: $0) }
        let savedPopupList = savedPopupDto.compactMap { Popup(from: $0) }

        savedPopupList.forEach { savedPopup in
            recentPopupList.indices.filter {
                recentPopupList[$0] == savedPopup
            }.forEach {
                recentPopupList[$0] = savedPopup
            }
        }

        recentPopupList = recentPopupList.filter { shouldShow(popup: $0) }

        DispatchQueue.main.async { [recentPopupList] in
            appState.popup.currentList = recentPopupList
            appState.popup.shouldShowPopup = recentPopupList.isEmpty ? false : true
        }
    }

    func saveLastUpdate(popup: Popup) {
        var currentPopupList = appState.popup.currentList

        currentPopupList.indices.filter {
            currentPopupList[$0] == popup
        }.forEach {
            currentPopupList[$0].lastUpdate = Date()
        }

        let currentPopupListDto = currentPopupList.compactMap { PopupDto(with: $0) }

        DispatchQueue.main.async {
            appState.popup.currentList = currentPopupList
        }

        userDefaultsRepository.set([PopupDto].self, key: .popupList, value: currentPopupListDto)
    }

    func shouldShow(popup: Popup) -> Bool {
        guard let lastUpdate = popup.lastUpdate else {
            return true
        }
        return Date().daysFrom(lastUpdate) > popup.hiddenDays
    }

    func showNextPopup() {
        if appState.popup.currentIndex + 1 >=
            appState.popup.currentList.count
        {
            appState.popup.shouldShowPopup = false
        } else {
            appState.popup.currentIndex += 1
        }
    }
}

class FakePopupService: PopupServiceProtocol {
    func getRecentPopupList() async throws {}
    func saveLastUpdate(popup _: Popup) {}
    func showNextPopup() {}
}
