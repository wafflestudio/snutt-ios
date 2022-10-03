//
//  AccountSettingViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import Combine
import SwiftUI

extension AccountSettingScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var currentUser: User?
        private var bag = Set<AnyCancellable>()
        
        override init(container: DIContainer) {
            super.init(container: container)
            
            appState.user.$current.assign(to: &$currentUser)
        }
        
        func deleteUser() {
            // TODO: implement
        }
    }
}
