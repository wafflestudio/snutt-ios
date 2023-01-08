//
//  FindLocalIdView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/12/28.
//

import SwiftUI

struct FindLocalIdView: View {
    @State private var email: String = ""
    @State private var showConfirmAlert: Bool = false
    let sendEmail: (String) async -> Bool

    @Environment(\.presentationMode) private var mode

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer().frame(height: 22)

            Text("아이디를 찾기 위해\n연동된 이메일 주소가 필요합니다.")
                .fixedSize()
                .font(STFont.title)

            Spacer().frame(height: 8)

            AnimatedTextField(label: "이메일", placeholder: "이메일을 입력하세요", text: $email, shouldFocusOn: true)

            Spacer().frame(height: 12)

            Button {
                Task {
                    showConfirmAlert = await sendEmail(email)
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
            .disabled(email.isEmpty)

            Spacer()
        }
        .navigationTitle("아이디 찾기")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
        .alert("전송 완료", isPresented: $showConfirmAlert) {
            Button("확인") {
                mode.wrappedValue.dismiss()
            }
        } message: {
            Text("\(email)로 아이디를 전송했습니다.")
        }
    }
}

struct FindLocalIDView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FindLocalIdView(sendEmail: { _ in
                print("send email")
                return true
            })
        }
    }
}
