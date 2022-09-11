//
//  SettingsMenu.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/14.
//

import SwiftUI

struct SettingsMenu: View {
    var title: String
    var destination: AnyView?
    var content: String?
    var destructive: Bool = false
    var action: (() -> Void)?
    var shouldNavigate: Bool {
        return destination != nil
    }

    /// 탭하면 다른 화면으로 이동하는 메뉴입니다.
    init<Content>(_ menu: SettingsMenuType, _ destination: () -> Content) where Content: View {
        title = menu.title
        self.destination = AnyView(destination())
    }

    /// 다른 화면으로 이동하지 않고 정보만 보여주거나 탭할 시 Navigation 외의 액션을 하는 메뉴입니다.
    init(_ menu: SettingsMenuType, content: String? = "", destructive: Bool = false, action: (() -> Void)? = nil) {
        title = menu.title
        self.content = content
        self.destructive = destructive
        self.action = action
    }

    var body: some View {
        if shouldNavigate {
            NavigationLink(destination: destination) {
                bodyView
            }
        } else {
            bodyView
                .contentShape(Rectangle())
                .onTapGesture {
                    (action ?? {})()
                }
        }
    }

    @ViewBuilder private var bodyView: some View {
        HStack {
            Text(title)
                .foregroundColor(destructive ? .red : .primary)
            Spacer()
            Text(content ?? "")
                .foregroundColor(Color.gray)
        }
    }
}

extension SettingsMenu: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(content)
        hasher.combine(shouldNavigate)
    }

    static func == (lhs: SettingsMenu, rhs: SettingsMenu) -> Bool {
        return lhs.title == rhs.title && lhs.shouldNavigate == rhs.shouldNavigate && lhs.content == rhs.content
    }
}

// TODO: Move to appropriate directory
protocol SettingsMenuType {
    var title: String { get }
}

enum Settings: SettingsMenuType {
    case accountSetting
    case timetableSetting
    case showVersionInfo
    case developerInfo
    case userSupport
    case licenseInfo
    case termsOfService
    case privacyPolicy
    case logout

    var title: String {
        switch self {
        case .accountSetting: return "계정 관리"
        case .timetableSetting: return "시간표 설정"
        case .showVersionInfo: return "버전 정보"
        case .developerInfo: return "개발자 정보"
        case .userSupport: return "개발자 괴롭히기"
        case .licenseInfo: return "라이센스 정보"
        case .termsOfService: return "서비스 약관"
        case .privacyPolicy: return "개인정보처리방침"
        case .logout: return "로그아웃"
        }
    }
}

enum AccountSettings: SettingsMenuType {
    case addLocalId
    case showLocalId
    case changePassword
    case makeFbConnection
    case showFbName
    case deleteFbConnection
    case showEmail
    case deleteAccount

    var title: String {
        switch self {
        case .addLocalId: return "아이디/비밀번호 추가"
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