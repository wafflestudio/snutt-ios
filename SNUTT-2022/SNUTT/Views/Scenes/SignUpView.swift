//
//  SignUpView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/01.
//

import SwiftUI

struct SignUpView: View {
    var displayMode: DisplayMode = .register
    var registerLocalId: (String, String, String) async -> Void // id, password, email

    enum DisplayMode: String {
        case register = "계정 만들기"
        case attach = "계정 추가하기"
    }

    @State private var id: String = ""
    @State private var password: String = ""
    @State private var password2: String = ""
    @State private var email: String = ""

    var isButtonDisabled: Bool {
        id.isEmpty || password.isEmpty || password2.isEmpty || email.isEmpty || password != password2
    }

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                AnimatedTextField(label: "아이디", placeholder: "아이디를 입력하세요.", text: $id, shouldFocusOn: true)
                AnimatedTextField(label: "비밀번호", placeholder: "비밀번호를 입력하세요.", text: $password, secure: true)
                AnimatedTextField(label: "비밀번호 확인", placeholder: "비밀번호를 한번 더 입력하세요.", text: $password2, secure: true)
                AnimatedTextField(label: "이메일", placeholder: "이메일 주소를 입력하세요.", text: $email)
            }

            Spacer()

            VStack {
                if displayMode == .register {
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        Text("아래 버튼을 누르시면 **일반 이용 약관**에 동의하시게 됩니다.".markdown)
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.3)))
                    }
                }

                Button {
                    Task {
                        await registerLocalId(id, password, email)
                        resignFirstResponder()
                    }
                } label: {
                    Text(displayMode.rawValue)
                        .padding(.vertical, 5)
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(STColor.cyan)
                .disabled(isButtonDisabled)
                .animation(.customSpring, value: isButtonDisabled)
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(displayMode.rawValue)
    }
}

#if DEBUG
    struct SignUpScene_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                SignUpView { localId, localPassword, email in
                    print(localId, localPassword, email)
                }
            }
        }
    }
#endif
