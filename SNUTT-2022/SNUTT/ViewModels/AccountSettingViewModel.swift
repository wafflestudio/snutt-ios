//
//  AccountSettingViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import Foundation
import SwiftUI

class AccountSettingViewModel {
    var container: DIContainer
    
    var menuList: [[Menu]] {
        return [
            [Menu("아이디 비번 추가", AnyView(DeveloperInfoScene()))],
            [Menu("페이스북 이름", currentUser.facebookName ?? "(없음)"),
             Menu("페이스북 연동 취소", AnyView(DeveloperInfoScene()))],
            [Menu("이메일", currentUser.email ?? "(없음)")],
            [Menu("회원탈퇴", AnyView(TermsOfServiceScene()))]
        ]
    }
    
    init(container: DIContainer) {
        self.container = container
    }

    private var appState: AppState {
        container.appState
    }

    var currentUser: User {
        appState.currentUser
    }

}
