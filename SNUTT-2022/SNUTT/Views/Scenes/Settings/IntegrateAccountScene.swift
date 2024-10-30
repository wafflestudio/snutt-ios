//
//  IntegrateAccountScene.swift
//  SNUTT
//
//  Created by 이채민 on 7/3/24.
//

import SwiftUI

struct IntegrateAccountScene: View {
    @ObservedObject var viewModel: ViewModel
    @State private var isDisconnectKakaoAlertPresented: Bool = false
    @State private var isDisconnectGoogleAlertPresented: Bool = false
    @State private var isDisconnectAppleAlertPresented: Bool = false
    @State private var isDisconnectFacebookAlertPresented: Bool = false

    var body: some View {
        List {
            if viewModel.currentSocialProvider?.kakao == true {
                SettingsButtonItem(title: "카카오 계정 연동 해제", role: .destructive) {
                    isDisconnectKakaoAlertPresented = true
                }
            } else {
                SettingsButtonItem(title: "카카오 계정 연동") {
                    viewModel.performKakaoSignIn()
                }
            }
            if viewModel.currentSocialProvider?.google == true {
                SettingsButtonItem(title: "구글 계정 연동 해제", role: .destructive) {
                    isDisconnectGoogleAlertPresented = true
                }
            } else {
                SettingsButtonItem(title: "구글 계정 연동") {
                    viewModel.performGoogleSignIn()
                }
            }
//            if (viewModel.currentSocialProvider?.apple == true) {
//                SettingsButtonItem(title: "애플 계정 연동 해제", role: .destructive) {
//                    isDisconnectAppleAlertPresented = true
//                }
//            } else {
//                SettingsButtonItem(title: "애플 계정 연동") {
//
//                }
//            }
            if viewModel.currentSocialProvider?.facebook == true {
                SettingsButtonItem(title: "페이스북 계정 연동 해제", role: .destructive) {
                    isDisconnectFacebookAlertPresented = true
                }
            } else {
                SettingsButtonItem(title: "페이스북 계정 연동") {
                    viewModel.performFacebookSignIn()
                }
            }
        }
        .alert("카카오 계정 연동을 해제하시겠습니까?", isPresented: $isDisconnectKakaoAlertPresented) {
            Button("취소", role: .cancel, action: {})
            Button("해제", role: .destructive, action: {
                Task {
                    await viewModel.detachKakao()
                }
            })
        }
        .alert("구글 계정 연동을 해제하시겠습니까?", isPresented: $isDisconnectGoogleAlertPresented) {
            Button("취소", role: .cancel, action: {})
            Button("해제", role: .destructive, action: {
                Task {
                    await viewModel.detachGoogle()
                }
            })
        }
//        .alert("애플 계정 연동을 해제하시겠습니까?", isPresented: $isDisconnectAppleAlertPresented) {
//            Button("취소", role: .cancel, action: {})
//            Button("해제", role: .destructive, action: {
//                Task {
//
//                }
//            })
//        }
        .alert("페이스북 계정 연동을 해제하시겠습니까?", isPresented: $isDisconnectFacebookAlertPresented) {
            Button("취소", role: .cancel, action: {})
            Button("해제", role: .destructive, action: {
                Task {
                    await viewModel.detachFacebook()
                }
            })
        }
        .navigationTitle("SNS 계정 연동 및 해제")
    }
}

#if DEBUG
    struct IntegrateAccountScene_Previews: PreviewProvider {
        static var previews: some View {
            IntegrateAccountScene(viewModel: .init(container: .preview))
        }
    }
#endif
