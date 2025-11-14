//
//  DiaryQuestionAnswerRow.swift
//  SNUTT
//
//  Created by 최유림 on 11/2/25.
//

import SwiftUI

struct DiaryQuestionAnswerRow: View {
    
    let question: String
    let answer: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(question)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(
                    colorScheme == .dark
                    ? STColor.alternative
                    : STColor.assistive
                )
                .frame(width: 80, alignment: .leading)
            Text(answer)
                .font(.system(size: 14))
                .foregroundStyle(
                    colorScheme == .dark
                    ? STColor.assistive
                    : STColor.darkerGray
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .multilineTextAlignment(.leading)
    }
}
