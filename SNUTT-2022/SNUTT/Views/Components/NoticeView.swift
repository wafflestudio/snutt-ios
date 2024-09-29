//
//  NoticeView.swift
//  SNUTT
//
//  Created by 최유림 on 9/29/24.
//

import SwiftUI

struct NoticeView: View {
    let title: String?
    let content: String?
    let sendFeedback: (String, String) async -> Bool

    @State private var pushToFeedBackView = false

    var body: some View {
        VStack(spacing: 32) {
            Image("warning.cat")
            VStack(spacing: 8) {
                if let title = title {
                    Text(title)
                        .font(STFont.title.font)
                }
                if let content = content {
                    Text(content)
                        .font(STFont.detailLabel.font)
                        .multilineTextAlignment(.center)
                }
                Spacer().frame(height: 4)
                Button {
                    pushToFeedBackView = true
                } label: {
                    Text("문의사항 보내기")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            STColor.cyan
                        )
                        .clipShape(.capsule)
                }
            }
        }
        .padding(.horizontal, 48)
        .background(
            NavigationLink("", isActive: $pushToFeedBackView) {
                UserSupportView(email: nil, sendFeedback: sendFeedback)
            }
        )
    }
}
