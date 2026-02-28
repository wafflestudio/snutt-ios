//
//  QuestionAnswerSection.swift
//  SNUTT
//
//  Created by 최유림 on 11/3/25.
//

import SwiftUI

struct QuestionAnswerSection: View {
    var allowMultipleAnswers: Bool = false
    let questionItem: QuestionItem
    let selected: ([AnswerOption]) -> ()
    
    @State var selectedOptions: [AnswerOption] = []
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text(questionItem.question)
                    .font(STFont.semibold15.font)
                    .foregroundStyle(.primary)
                if let subLabel = questionItem.subQuestion {
                    Text(subLabel)
                        .font(STFont.regular13.font)
                        .foregroundStyle(STColor.alternative)
                }
                Spacer()
            }
            WrappedOptionChipList(
                selectedOptions: $selectedOptions,
                answerOptions: questionItem.options
            )
        }
        .onChange(of: selectedOptions) { options in
            selected(options)
        }
    }
}
