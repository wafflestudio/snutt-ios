//
//  BaseSettingViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/19.
//

import Foundation

class BaseSettingViewModel: BaseViewModel {
    private var userState: UserState {
        appState.user
    }
    
    func makeMenuList(menus: [[MenuType]]) -> [[Menu]] {
        var menuList: [[Menu]] = []
        for section in menus {
            var temp: [Menu] = []
            for title in section {
                let menu = self.makeMenu(from: title)
                temp.append(menu)
            }
            menuList.append(temp)
        }
        return menuList
    }
    
    func makeMenu(from type: MenuType) -> Menu {
        switch(type) {
        case .accountSetting:
            return Menu(.accountSetting) {
                AccountSettingScene(viewModel: AccountSettingViewModel(container: container))
            }
        case .timetableSetting:
            return Menu(.timetableSetting) {
                TimetableSettingScene()
            }
        case .showVersionInfo:
            return Menu(.showVersionInfo)
        case .developerInfo:
            return Menu(.developerInfo)
        case .userSupport:
            return Menu(.userSupport) {
                UserSupportScene()
            }
        case .licenseInfo:
            return Menu(.licenseInfo) {
                LicenseScene()
            }
        case .termsOfService:
            return Menu(.termsOfService) {
                TermsOfServiceScene()
            }
        case .privacyPolicy:
            return Menu(.privacyPolicy) {
                PrivacyPolicyScene()
            }
        case .logout:
            return Menu(.logout, destructive: true)
        case .addLocalId:
            return Menu(.addLocalId) {
                AddLocalIdScene(viewModel: AddLocalIdViewModel(container: container))
            }
        case .showLocalId:
            return Menu(.showLocalId, userState.current?.localId ?? "(없음)")
        case .changePassword:
            return Menu(.changePassword)
        case .makeFbConnection:
            return Menu(.makeFbConnection)
        case .showFbName:
            return Menu(.showFbName, userState.current?.fbName ?? "(없음)")
        case .deleteFbConnection:
            return Menu(.deleteFbConnection)
        case .showEmail:
            return Menu(.showEmail, self.appState.user.current?.email ?? "(없음)")
        case .deleteAccount:
            return Menu(.deleteAccount, destructive: true)
        }
    }
}

enum MenuType {
    case accountSetting
    case timetableSetting
    case showVersionInfo
    case developerInfo
    case userSupport
    case licenseInfo
    case termsOfService
    case privacyPolicy
    case logout
    
    case addLocalId
    case showLocalId
    case changePassword
    case makeFbConnection
    case showFbName
    case deleteFbConnection
    case showEmail
    case deleteAccount
    
    /// 메뉴를 나타내는 cell의 좌측에 들어갈 내용입니다.
    var title: String {
        switch(self) {
        case .accountSetting: return "계정 관리"
        case .timetableSetting: return "시간표 설정"
        case .showVersionInfo: return "버전 정보"
        case .developerInfo: return "개발자 정보"
        case .userSupport: return "개발자 괴롭히기"
        case .licenseInfo: return "라이센스 정보"
        case .termsOfService: return "서비스 약관"
        case .privacyPolicy: return "개인정보처리방침"
        case .logout: return "로그아웃"
            
        case .addLocalId: return "아이디 비번 추가"
        case .showLocalId: return "아이디"
        case .changePassword: return "비밀번호 변경"
        case .makeFbConnection: return "페이스북 연동"
        case .showFbName: return "페이스북 이름"
        case .deleteFbConnection: return "페이스북 연동 취소"
        case .showEmail: return "이메일"
        case .deleteAccount: return "회원탈퇴"
        }
    }
}

