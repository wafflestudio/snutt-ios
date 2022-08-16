//
//  Menu.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/14.
//

import SwiftUI

struct Menu: Hashable {
    var title: String
    var contentView: AnyView?
    var showOnly: Bool {
        return contentView == nil
    }
    var content: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(showOnly)
    }

    @ViewBuilder func show() -> MenuView {
        MenuView(menu: self, destination: contentView)
    }
    
    /// 탭하면 다른 화면으로 navigate되는 메뉴입니다. 메뉴명 title과 이동할 View를 인자로 받습니다.
    init<Content>(_ menu: MenuType, _ content: () -> Content) where Content: View {
        self.title = menu.title
        self.contentView = AnyView(content())
    }

    /// 다른 화면으로 이동하지 않고, 정보만 보여주는 메뉴입니다. 메뉴명 title을 필수로 받고, 필요에 따라 추가로 보여줄 정보인 content를 인자로 받습니다.
    init(_ menu: MenuType, _ content: String? = "") {
        self.title = menu.title
        self.content = content
    }
    
    static func == (lhs: Menu, rhs: Menu) -> Bool {
        return lhs.title == rhs.title && lhs.showOnly == rhs.showOnly
    }
}

struct MenuView: View {

    @State var menu: Menu
    @State var destination: AnyView?
    
    var body: some View {
        if menu.showOnly {
            HStack {
                Text(menu.title)
                Spacer()
                Text(menu.content ?? "")
                    .foregroundColor(Color.gray)
            }
        } else {
            NavigationLink(destination: destination) {
                Text(menu.title)
            }
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
