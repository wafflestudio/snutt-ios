//
//  SignUpView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/01.
//

import SwiftUI

struct SignUpView: View {
    var displayMode: DisplayMode = .register
    var registerLocalId: (String, String, String) async -> Bool // id, password, email
    let domain: String = "@snu.ac.kr"

    enum DisplayMode: String {
        case register = "계정 만들기"
        case attach = "계정 추가하기"
    }

    @State private var id: String = ""
    @State private var password: String = ""
    @State private var password2: String = ""
    @State private var email: String = ""
    @State private var pushToEmailVerificationView: Bool = false
    @State private var pushToCodeVerificationView: Bool = false
    @State private var pushToTimetableScene: Bool = false

    var isButtonDisabled: Bool {
        id.isEmpty || password.isEmpty || password2.isEmpty || email.isEmpty || password != password2
    }

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                AnimatedTextField(label: "아이디", placeholder: "영문 혹은 숫자 4-32자 이내", text: $id, keyboardType: .asciiCapable, shouldFocusOn: true)
                AnimatedTextField(label: "비밀번호", placeholder: "영문과 숫자 모두 포함 6-20자 이내", text: $password, keyboardType: .asciiCapable, secure: true)
                AnimatedTextField(label: "비밀번호 확인", placeholder: "비밀번호를 한번 더 입력하세요", text: $password2, keyboardType: .asciiCapable, secure: true)
                HStack {
                    AnimatedTextField(label: "이메일", placeholder: "서울대학교 메일 주소를 입력하세요", text: $email, keyboardType: .asciiCapable)
                    Text(domain)
                        .font(STFont.detailLabel)
                        .foregroundColor(.primary)
                        .alignmentGuide(VerticalAlignment.center) { _ in 0 }
                }
            }

            Spacer()

            VStack {
                if displayMode == .register {
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        Text("아래 버튼을 누르면 **일반 이용 약관**에 동의하시게 됩니다.".markdown)
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.3)))
                    }
                }

                Button {
                    Task {
                        if await registerLocalId(id, password, email + domain) {
                            resignFirstResponder()
                        }
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
        .background(
            NavigationLink(isActive: $pushToEmailVerificationView) {
                EmailVerificationView(email: email + domain,
                                      pushToCodeVerificationView: $pushToCodeVerificationView,
                                      pushToTimetableScene: $pushToTimetableScene)
            } label: {
                EmptyView()
            }
        )
    }
}

#if DEBUG
    struct SignUpScene_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                SignUpView { localId, localPassword, email in
                    print(localId, localPassword, email)
                    return false
                }
            }
        }
    }
#endif
