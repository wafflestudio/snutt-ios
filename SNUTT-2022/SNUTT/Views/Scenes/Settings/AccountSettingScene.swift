//
//  AccountSettingScene.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import SwiftUI

struct AccountSettingScene: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        List {
            Section {
                if let username = viewModel.currentUser?.localId {
                    SettingsTextItem(title: "아이디", detail: username)
                    SettingsLinkItem(title: "비밀번호 변경") {
                        EmptyView()
                    }
                } else {
                    SettingsLinkItem(title: "아이디 / 비밀번호 추가") {
                        EmptyView()
                    }
                }
            }
            Section {
                if let facebookName = viewModel.currentUser?.fbName {
                    SettingsTextItem(title: "페이스북 이름", detail: facebookName)
                    SettingsButtonItem(title: "페이스북 연동 취소", role: .destructive) {
                        print("로그아웃")
                    }
                } else {
                    SettingsButtonItem(title: "페이스북 연동") {
                        print("연동")
                    }
                }
            }
            Section {
                SettingsTextItem(title: "이메일", detail: viewModel.currentUser?.email ?? "(없음)")
            }
            Section {
                SettingsButtonItem(title: "회원 탈퇴", role: .destructive) {
                    print("로그아웃")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("계정 관리")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#if DEBUG
    struct AccountSettingScene_Previews: PreviewProvider {
        static var previews: some View {
            AccountSettingScene(viewModel: .init(container: .preview))
        }
    }
#endif
