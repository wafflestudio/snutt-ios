//
//  SettingViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class SettingViewModel {
    var container: DIContainer
    
    var menuList: [[Menu]] {
        return [
            [Menu("계정 관리", AnyView(TimetableSettingScene())),
             Menu("시간표 설정", AnyView(TimetableSettingScene()))],
            [Menu("버전 정보")],
            [Menu("개발자 정보", AnyView(DeveloperInfoScene())),
             Menu("개발자 괴롭히기", AnyView(DeveloperInfoScene()))],
            [Menu("라이센스 정보", AnyView(LicenseScene())),
             Menu("서비스 약관", AnyView(TermsOfServiceScene())),
             Menu("개인정보처리방침", AnyView(PrivacyPolicyScene()))],
            [Menu("로그아웃", AnyView(TermsOfServiceScene()))]
        ]
    }
    
    var appVersion: String {
        //appState.setting.appVersion ==
        return ""
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

    func updateCurrentUser(user: User) {
        appState.currentUser = user
    }
    
    #if DEBUG
    // for test (will be removed)
    
    let sampleAppState: AppState = .preview
    
    func setRandomLecture() {
        let sampleLectures = sampleAppState.currentTimetable.lectures
        
        appState.setting.exampleLecture = sampleLectures[Int.random(in: 0..<sampleLectures.count)].title
        print("\(appState.setting.exampleLecture)(으)로 값 변경")
    }
    
    func printSavedLecture() {
        print(appState.setting.exampleLecture)
    }
    #endif
}
