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
    
    private var setting: Setting {
        appState.setting
    }
    
    private var userService: UserServiceProtocol {
        container.services.userService
    }
}
