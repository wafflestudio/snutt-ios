//
//  DiaryQuestionAnswerRow.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct DiaryQuestionAnswerRow: View {
    let question: String
    let answer: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(question)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.questionLabel)
                .frame(width: 80, alignment: .leading)

            Text(answer)
                .font(.system(size: 14))
                .foregroundStyle(Color.answerLabel)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .multilineTextAlignment(.leading)
    }
}

#Preview {
    VStack(spacing: 12) {
        DiaryQuestionAnswerRow(question: "수강신청", answer: "널널해요")
        DiaryQuestionAnswerRow(question: "드랍여부", answer: "모르겠어요")
        DiaryQuestionAnswerRow(question: "수업 첫인상", answer: "두려워요")
        DiaryQuestionAnswerRow(question: "남기고 싶은 말", answer: "오티 했어용... 생각보다 과제가 많을 것 같아요.")
    }
    .padding()
}
