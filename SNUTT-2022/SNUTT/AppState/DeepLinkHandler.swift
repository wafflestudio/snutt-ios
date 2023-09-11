//
//  DeepLinkHandler.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/05/27.
//

import Foundation

@MainActor
struct DeepLinkHandler {
    typealias Parameters = [URLQueryItem]

    let appState: AppState

    func open(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        switch urlComponents.host {
        case "notifications":
            handleNotification(parameters: urlComponents.queryItems)
        case "vacancy":
            handleVacancy(parameters: urlComponents.queryItems)
        case "friends":
            handleFriends(parameters: urlComponents.queryItems)
        default:
            return
        }
    }
}

extension DeepLinkHandler {
    private func handleNotification(parameters _: Parameters?) {
        appState.system.selectedTab = .settings
        appState.routing.settingScene.pushToNotification = true
    }

    private func handleVacancy(parameters _: Parameters?) {
        appState.system.selectedTab = .settings
        appState.routing.settingScene.pushToVacancy = true
    }

    private func handleFriends(parameters _: Parameters?) {
        appState.system.selectedTab = .friends
    }
}
