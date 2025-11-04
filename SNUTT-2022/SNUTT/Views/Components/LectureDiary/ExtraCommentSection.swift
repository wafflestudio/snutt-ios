//
//  ExtraCommentTextField.swift
//  SNUTT
//
//  Created by 최유림 on 11/3/25.
//

import SwiftUI

struct ExtraReviewSection: View {
    
    @Binding var extraReview: String
    @State private var extraReviewExpanded: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            headerView()
            if extraReviewExpanded {
                ExtraCommentTextField(extraReview: $extraReview)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            colorScheme == .dark ? STColor.groupBackground : .white
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            HStack(spacing: 6) {
                Text("더 남기고 싶은 말을 작성해주세요.")
                    .font(STFont.semibold15.font)
                    .foregroundStyle(.primary)
                Text("선택")
                    .font(STFont.regular13.font)
                    .foregroundStyle(
                        colorScheme == .dark
                        ? STColor.gray30
                        : STColor.alternative
                    )
            }
            Spacer()
            Image("chevron.down")
                .rotationEffect(.init(degrees: extraReviewExpanded ? 180.0 : 0))
        }
        .onTapGesture {
            withAnimation {
                extraReviewExpanded.toggle()
            }
        }
    }
}

struct ExtraCommentTextField: View {
    
    @Binding var extraReview: String
    @State private var wordCount = 0
    private let wordLimit = 200
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Divider().frame(height: 0.8)
            .frame(maxWidth: .infinity)
            .foregroundStyle(
                colorScheme == .dark
                ? STColor.gray30.opacity(0.4)
                : STColor.lightest
            )
        VStack(spacing: 0) {
            UITextEditor(
                "오늘 수업에서 배운 내용, 느낀 점 등을 간단하게\n적어보세요.",
                text: $extraReview
            ) { textView in
                textView.backgroundColor = .clear
                textView.textContainerInset = .zero
                textView.textContainer.lineFragmentPadding = 0
                textView.font = STFont.regular14
            } onChange: { textView in
                wordCount = textView.text.count
            }
            .padding(.top, 8)
            
            HStack {
                Spacer()
                Text("\(wordCount)")
                    .font(STFont.bold15.font)
                    .foregroundColor(STColor.cyan) +
                Text("/\(wordLimit)")
                    .font(STFont.regular14.font)
                    .foregroundColor(
                        colorScheme == .dark
                        ? STColor.darkerGray
                        : STColor.alternative
                    )
            }
        }
        .frame(height: 120)
    }
}
