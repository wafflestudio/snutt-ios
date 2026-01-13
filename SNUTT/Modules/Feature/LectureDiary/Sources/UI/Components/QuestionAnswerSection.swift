//
//  QuestionAnswerSection.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct QuestionAnswerSection: View {
    let questionItem: QuestionItem
    let allowMultipleAnswers: Bool
    let onAnswerSelected: ([AnswerOption]) -> Void

    @State private var selectedOptions: [AnswerOption] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text(questionItem.question)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                if let subQuestion = questionItem.subQuestion {
                    Text(subQuestion)
                        .font(.system(size: 13))
                        .foregroundStyle(SharedUIComponentsAsset.alternative.swiftUIColor)
                }

                Spacer()
            }

            WrappedOptionChipList(
                selectedOptions: $selectedOptions,
                answerOptions: questionItem.options,
                allowMultiple: allowMultipleAnswers
            )
        }
        .onChange(of: selectedOptions) { _, newValue in
            onAnswerSelected(newValue)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        QuestionAnswerSection(
            questionItem: QuestionItem(
                id: "1",
                question: "수강신청",
                subQuestion: nil,
                options: [
                    AnswerOption(id: "1", content: "널널해요"),
                    AnswerOption(id: "2", content: "무난해요"),
                    AnswerOption(id: "3", content: "어려웠어요"),
                ]
            ),
            allowMultipleAnswers: false,
            onAnswerSelected: { _ in }
        )

        Divider()

        QuestionAnswerSection(
            questionItem: QuestionItem(
                id: "2",
                question: "오늘 무엇을 했나요?",
                subQuestion: "중복 가능",
                options: [
                    AnswerOption(id: "1", content: "이론수업"),
                    AnswerOption(id: "2", content: "토론수업"),
                    AnswerOption(id: "3", content: "발표수업"),
                    AnswerOption(id: "4", content: "실습수업"),
                ]
            ),
            allowMultipleAnswers: true,
            onAnswerSelected: { _ in }
        )
    }
    .padding()
}
