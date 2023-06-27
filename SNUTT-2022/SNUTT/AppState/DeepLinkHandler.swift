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
            return
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
}
