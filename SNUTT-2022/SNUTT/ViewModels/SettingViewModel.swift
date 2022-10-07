//
//  SettingViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class SettingViewModel: BaseViewModel {
    override init(container: DIContainer) {
        super.init(container: container)
    }

    func logout() async {
        do {
            try await services.authService.logout()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func fetchUser() async {
        do {
            try await services.userService.fetchUser()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
    
    var versionString: String {
        guard let appVersion = AppMetadata.appVersion.value,
              let buildNumber = AppMetadata.buildNumber.value,
              let appType = AppMetadata.appType.value
        else {
            return "버전 정보 없음"
        }
        return "v\(appVersion)-\(appType).\(buildNumber)"
    }
}
