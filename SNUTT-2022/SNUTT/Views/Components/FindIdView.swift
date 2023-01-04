//
//  FindIdView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/12/28.
//

import SwiftUI

struct FindIdView: View {
    @Binding var email: String
    let sendEmail: () async -> Void

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
                    await sendEmail()
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
            .onTapGesture {}

            Spacer()
        }
        .navigationTitle("아이디 찾기")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
    }
}

struct FindIDView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FindIdView(email: .constant("example@wafflestudio.com"), sendEmail: {
                print("send email")
            })
        }
    }
}
