//
//  LoginScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/02.
//

import SwiftUI

struct LoginScene: View {
    @ObservedObject var viewModel: ViewModel

    @State private var localId: String = ""
    @State private var localPassword: String = ""
    @State private var pushToFindLocalIdView: Bool = false
    @State private var pushToResetPasswordScene: Bool = false
    
    @Binding var moveToTimetableScene: Bool

    var isButtonDisabled: Bool {
        localId.isEmpty || localPassword.isEmpty
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 15) {
                AnimatedTextField(label: "아이디", placeholder: "아이디를 입력하세요", text: $localId, shouldFocusOn: true)
                AnimatedTextField(label: "비밀번호", placeholder: "비밀번호를 입력하세요", text: $localPassword, secure: true)

                HStack {
                    Group {
                        Text("아이디 찾기")
                            .underline()
                            .onTapGesture {
                                pushToFindLocalIdView = true
                            }

                        Text("|")

                        Text("비밀번호 재설정")
                            .underline()
                            .onTapGesture {
                                pushToResetPasswordScene = true
                            }
                    }
                    .font(STFont.detailLabel)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                }
            }

            Spacer()

            Button {
                Task {
                    await viewModel.loginWithLocalId(localId: localId, localPassword: localPassword)
                    moveToTimetableScene = true
                    resignFirstResponder()
                }
            } label: {
                Text("로그인")
                    .padding(.vertical, 5)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(STColor.cyan)
            .disabled(isButtonDisabled)
            .animation(.customSpring, value: isButtonDisabled)
        }
        .padding()
        .navigationTitle("로그인")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            Group {
                NavigationLink(destination:
                    FindLocalIdView(sendEmail: viewModel.findLocalId(with:)),
                    isActive: $pushToFindLocalIdView) { EmptyView() }

                NavigationLink(destination: ResetPasswordScene(viewModel: .init(container: viewModel.container), showResetPasswordScene: $pushToResetPasswordScene),
                               isActive: $pushToResetPasswordScene) { EmptyView() }
            }
        )
    }
}

extension LoginScene {
    class ViewModel: BaseViewModel, ObservableObject {
        func loginWithLocalId(localId: String, localPassword: String) async {
            do {
                try await services.authService.loginWithLocalId(localId: localId, localPassword: localPassword)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func findLocalId(with email: String) async -> Bool {
            do {
                try await services.authService.findLocalId(email: email)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }
    }
}

#if DEBUG
    struct LoginScene_Previews: PreviewProvider {
        static var previews: some View {
            LoginScene(viewModel: .init(container: .preview), moveToTimetableScene: .constant(false))
        }
    }
#endif
