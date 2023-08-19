//
//  AccountSettingScene.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import SwiftUI

struct AccountSettingScene: View {
    @ObservedObject var viewModel: ViewModel
    @State private var isDisconnectFBAlertPresented: Bool = false
    @State private var isDeleteAccountAlertPresented: Bool = false
    @State private var isNicknameCopiedToPasteboard: Bool = false

    var body: some View {
        List {
            if let nickname = viewModel.currentUser?.nickname {
                Section {
                    SettingsLinkItem(title: "닉네임 변경", detail: nickname.fullString) {
                        ChangeNicknameView(old: nickname.name, tag: nickname.tag) { new in
                            await viewModel.changeNickname(to: new)
                        }
                    }
                    
                    SettingsTextItem(title: "닉네임 복사하기", detailSystemImage: "square.on.square")
                        .onTapGesture {
                            UIPasteboard.general.string = nickname.fullString
                            isNicknameCopiedToPasteboard = true
                        }
                }
            }
            
            if let localId = viewModel.currentUser?.localId {
                Section {
                    SettingsTextItem(title: "아이디", detail: localId)
                    SettingsLinkItem(title: "비밀번호 변경") {
                        ChangePasswordView { old, new in
                            await viewModel.changePassword(from: old, to: new)
                        }
                    }
                }
            } else {
                Section {
                    SettingsLinkItem(title: "아이디 / 비밀번호 추가") {
                        SignUpView(displayMode: .attach, registerLocalId: { localId, localPassword, _ in
                            await viewModel.attachLocalId(localId: localId, localPassword: localPassword)
                        }, pushToTimetableScene: .constant(false))
                    }
                }
            }

            if let facebookName = viewModel.currentUser?.fbName {
                Section {
                    SettingsTextItem(title: "페이스북 이름", detail: facebookName)
                    SettingsButtonItem(title: "페이스북 연동 해제", role: .destructive) {
                        isDisconnectFBAlertPresented = true
                    }
                }
            } else {
                Section {
                    SettingsButtonItem(title: "페이스북 연동") {
                        viewModel.performFacebookSignIn()
                    }
                }
            }

            Section {
                SettingsTextItem(title: "이메일", detail: viewModel.currentUser?.email ?? "(없음)")
            }
            Section {
                SettingsButtonItem(title: "회원 탈퇴", role: .destructive) {
                    isDeleteAccountAlertPresented = true
                }
            }
        }
        .animation(.customSpring, value: viewModel.currentUser?.fbName)
        .animation(.customSpring, value: viewModel.currentUser?.localId)
        .listStyle(.insetGrouped)
        .navigationTitle("계정 관리")
        .navigationBarTitleDisplayMode(.inline)
        .alert("닉네임이 클립보드에 복사되었습니다.", isPresented: $isNicknameCopiedToPasteboard) {
            Button("확인") {}
        }
        .alert("페이스북 연동 해제", isPresented: $isDisconnectFBAlertPresented) {
            Button("취소", role: .cancel, action: {})
            Button("해제", role: .destructive, action: {
                Task {
                    await viewModel.detachFacebook()
                }
            })
        } message: {
            Text("페이스북 연동을 해제하시겠습니까?")
        }
        .alert("회원 탈퇴", isPresented: $isDeleteAccountAlertPresented) {
            Button("회원 탈퇴", role: .destructive) {
                Task {
                    await viewModel.deleteUser()
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("SNUTT 회원 탈퇴를 하시겠습니까?")
        }
    }
}

#if DEBUG
    struct AccountSettingScene_Previews: PreviewProvider {
        static var previews: some View {
            AccountSettingScene(viewModel: .init(container: .preview))
        }
    }
#endif
