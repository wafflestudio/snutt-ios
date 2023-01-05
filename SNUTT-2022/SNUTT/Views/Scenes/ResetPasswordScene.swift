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
    @State private var showEmailAlert: Bool = false
    @State private var pushToVerificationView: Bool = false
    @State private var pushToResetPasswordView: Bool = false
    @Binding var showResetPasswordScene: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer().frame(height: 22)

            Text("비밀번호 재설정을 위해\n연동된 아이디가 필요합니다.")
                .fixedSize()
                .font(STFont.title)

            Spacer().frame(height: 8)

            AnimatedTextField(label: "아이디", placeholder: "아이디를 입력하세요", text: $localId)

            Spacer().frame(height: 12)

            Button {
                Task {
                    showEmailAlert = await viewModel.checkLinkedEmail(localId: localId, email: $email)
                    resignFirstResponder()
                }
            } label: {
                Text("확인")
                    .font(STFont.title)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 0))
            .tint(STColor.cyan)
            .disabled(localId.isEmpty)

            Spacer()
        }
        .navigationTitle("비밀번호 재설정")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
        .alert("이메일 확인", isPresented: $showEmailAlert) {
            Button("전송") {
                Task {
                    if await viewModel.sendVerificationCode(to: email) {
                        pushToVerificationView = true
                    }
                }
            }

            Button("취소", role: .cancel) {}
        } message: {
            Text("아이디에 연동된 메일 주소는 \(email)입니다. 이 주소로 인증코드를 보낼까요?")
        }
        .onChange(of: pushToResetPasswordView) { newValue in
            if !newValue {
                showResetPasswordScene = false
            }
        }
        .background(
            Group {
                NavigationLink(destination:
                    VerificationCodeView(email: email, timeLimit: viewModel.timeLimit,
                                         sendVerificationCode: { _ in
                                             await viewModel.sendVerificationCode(to: email)
                                         }, checkVerificationCode: { code in
                                             pushToResetPasswordView = await viewModel.checkVerificationCode(localId: localId, code: code)
                                         }),
                    isActive: $pushToVerificationView) { EmptyView() }

                NavigationLink(destination:
                    ChangePasswordView(resetMode: true,
                                       resetPassword: { password in
                                           await viewModel.resetPassword(localId: localId, to: password)
                                       }),
                    isActive: $pushToResetPasswordView) { EmptyView() }
            }
        )
    }
}

extension ResetPasswordScene {
    class ViewModel: BaseViewModel, ObservableObject {
        var timeLimit: Int { 180 }

        func checkLinkedEmail(localId: String, email: Binding<String>) async -> Bool {
            do {
                try await services.authService.checkLinkedEmail(localId: localId, email: email)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
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

struct FindPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResetPasswordScene(viewModel: .init(container: .preview), showResetPasswordScene: .constant(true))
        }
    }
}
