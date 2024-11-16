//
//  ResetPasswordScene.swift
//  SNUTT
//
//  Created by 최유림 on 2022/12/25.
//

import SwiftUI

struct ResetPasswordScene: View {
    @ObservedObject var viewModel: ViewModel

    @State private var localId: String = ""
    @State private var email: String = ""
    @State private var maskedEmail: String?
    @State private var pushToVerificationView: Bool = false
    @State private var pushToNewPasswordView: Bool = false
    
    @Binding var showResetPasswordScene: Bool
    @Binding var changeTitle: Bool
    
    private var didSubmitId: Bool {
        maskedEmail != nil
    }
    
    private var titleLabel: String {
        didSubmitId
             ? "해당 아이디로 연동된 이메일입니다.\n전체 주소를 입력하여 인증코드를 받으세요."
             : "비밀번호 재설정을 위해\n연동된 아이디가 필요합니다."
    }
    
    private var buttonLabel: String {
        didSubmitId
             ? "인증코드 받기"
             : "확인"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 40) {
                Text(titleLabel)
                    .lineHeight(with: STFont.bold17, percentage: 145)

                // TODO: maskedEmail 이후로 disable
                AnimatedTextField(label: "아이디", placeholder: "아이디를 입력하세요", text: $localId, shouldFocusOn: true)
                
                if let maskedEmail = maskedEmail {
                    VStack(alignment: .leading, spacing: 12) {
                        AnimatedTextField(label: "이메일", placeholder: "전체 주소를 입력하세요", text: $email)
                        Text(maskedEmail)
                            .font(STFont.regular15.font)
                            .foregroundStyle(STColor.alternative)
                    }
                }
            }
            Spacer().frame(height: 48)
            VStack(spacing: 20) {
                RoundedRectButton(label: buttonLabel,
                                  tracking: didSubmitId ? 0 : 1.6,
                                  type: .max,
                                  disabled: didSubmitId ? email.isEmpty : localId.isEmpty) {
                    Task {
                        if didSubmitId, await viewModel.sendVerificationCode(to: email) {
                            pushToVerificationView = true
                        } else {
                            if let email = await viewModel.getLinkedEmail(localId: localId) {
                                maskedEmail = email
                                changeTitle = true
                                resignFirstResponder()
                            }
                        }
                    }
                }
                
                if let _ = maskedEmail {
                    Button {
                        changeTitle = false
                        maskedEmail = nil
                    } label: {
                        Text("나의 이메일 주소가 아닌가요?")
                            .foregroundStyle(STColor.assistive)
                            .font(STFont.medium14.font)
                    }
                }
            }

            Spacer()
        }
        .navigationTitle(pushToNewPasswordView
                         ? "처음으로"
                         : (pushToVerificationView ? "로그인" : "비밀번호 재설정"))
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 44)
        .padding(.horizontal, 20)
        .background(
            Group {
                NavigationLink(destination:
                    VerificationCodeView(mode: .resetPassword, email: email,
                                         sendVerificationCode: { _ in
                                             await viewModel.sendVerificationCode(to: email)
                                         }, checkVerificationCode: { code in
                                             pushToNewPasswordView = await viewModel.checkVerificationCode(localId: localId, code: code)
                                         }),
                    isActive: $pushToVerificationView) { EmptyView() }

                NavigationLink(destination:
                                EnterNewPasswordView(returnToEmailVerification: $pushToVerificationView) { password in
                        await viewModel.resetPassword(localId: localId, to: password)
                    },
                    isActive: $pushToNewPasswordView) { EmptyView() }
            }
        )
    }
}

extension ResetPasswordScene {
    class ViewModel: BaseViewModel, ObservableObject {
        func getLinkedEmail(localId: String) async -> String? {
            do {
                return try await services.authService.getLinkedEmail(localId: localId)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return nil
            }
        }

        func sendVerificationCode(to email: String) async -> Bool {
            do {
                try await services.authService.sendVerificationCode(email: email)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }

        func checkVerificationCode(localId: String, code: String) async -> Bool {
            do {
                try await services.authService.checkVerificationCode(localId: localId, code: code)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }

        func resetPassword(localId: String, to password: String) async -> Bool {
            do {
                try await services.authService.resetPassword(localId: localId, password: password)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }
    }
}

#if DEBUG
    struct FindPasswordView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ResetPasswordScene(viewModel: .init(container: .preview), showResetPasswordScene: .constant(true), changeTitle: .constant(false))
            }
        }
    }
#endif
