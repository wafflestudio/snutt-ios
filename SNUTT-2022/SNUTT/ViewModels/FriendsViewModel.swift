//
//  FriendsViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/15.
//

import Foundation

class FriendsViewModel: BaseViewModel, ObservableObject {
    override init(container: DIContainer) {
        super.init(container: container)
    }

    var accessToken: String? {
        appState.user.accessToken
    }

    func fetchReactNativeBundleUrl() async -> URL? {
        do {
            return try await services.friendsService.fetchReactNativeBundleUrl()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
        return nil
    }
}
