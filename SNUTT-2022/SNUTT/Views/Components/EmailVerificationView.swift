//
//  EmailVerificationView.swift
//  SNUTT
//
//  Created by 최유림 on 2023/07/04.
//

import SwiftUI

struct EmailVerificationView: View {
    let email: String

    @Binding var pushToCodeVerificationView: Bool
    var skipVerification: () -> Void
    var sendVerificationCode: () async -> Bool

    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 27)

            Text("강의평 서비스를 이용하기 위해\n이메일 인증이 필요합니다.\n\(email)에 대한 이메일 인증을\n진행하시겠습니까?")
                .fixedSize()
                .font(STFont.bold17.font)

            Spacer().frame(height: 18)

            Text("\"나중에 하기\"를 선택하더라도 강의평 서비스를 제외한 SNUTT의 모든 기능을 이용할 수 있습니다.")
                .font(STFont.regular14.font)

            Spacer().frame(height: 68)

            Group {
                Button {
                    Task {
                        pushToCodeVerificationView = await sendVerificationCode()
                    }
                } label: {
                    Text("확인")
                        .font(STFont.bold17.font)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
                .tint(STColor.cyan)

                Spacer().frame(height: 12)

                Button {
                    skipVerification()
                } label: {
                    Text("나중에 하기")
                        .font(STFont.bold17.font)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
                .tint(STColor.assistive)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 0))

            Spacer()
        }
        .navigationTitle("이메일 인증")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EmailVerificationView(email: "penggggg@snu.ac.kr", pushToCodeVerificationView: .constant(false), skipVerification: {}, sendVerificationCode: { false })
        }
        .navigationTitle("이메일 인증")
        .navigationBarTitleDisplayMode(.inline)
    }
}
