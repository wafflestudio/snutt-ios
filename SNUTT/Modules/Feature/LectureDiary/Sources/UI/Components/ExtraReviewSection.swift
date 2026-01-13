//
//  ExtraReviewSection.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct ExtraReviewSection: View {
    @Binding var extraReview: String
    @State private var isExpanded: Bool = false

    private let maxCharacters = 200

    var body: some View {
        VStack(spacing: 8) {
            headerView

            if isExpanded {
                Divider()
                    .frame(height: 0.8)
                    .foregroundStyle(Color.gray.opacity(0.3))

                textEditorView
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .backgroundStyle(
            light: .white,
            dark: SharedUIComponentsAsset.groupBackground.swiftUIColor
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var headerView: some View {
        HStack {
            HStack(spacing: 6) {
                Text(LectureDiaryStrings.lectureDiaryEditExtraCommentTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(LectureDiaryStrings.lectureDiaryEditExtraCommentOptional)
                    .font(.system(size: 13))
                    .foregroundStyle(
                        light: SharedUIComponentsAsset.alternative.swiftUIColor,
                        dark: SharedUIComponentsAsset.gray30.swiftUIColor
                    )
            }

            Spacer()

            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }

    private var textEditorView: some View {
        VStack(spacing: 0) {
            TextEditor(text: $extraReview)
                .font(.system(size: 14))
                .frame(height: 120)
                .scrollContentBackground(.hidden)
                .overlay(alignment: .topLeading) {
                    if extraReview.isEmpty {
                        Text(LectureDiaryStrings.lectureDiaryEditExtraCommentPlaceholder)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .allowsHitTesting(false)
                            .padding(.top, 8)
                    }
                }
                .padding(.top, 8)

            HStack(spacing: 0) {
                Spacer()
                Text("\(extraReview.count)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(SharedUIComponentsAsset.cyan.swiftUIColor)
                Text("/\(maxCharacters)")
                    .font(.system(size: 14))
                    .foregroundStyle(
                        light: SharedUIComponentsAsset.alternative.swiftUIColor,
                        dark: SharedUIComponentsAsset.darkerGray.swiftUIColor
                    )
            }
        }
        .onChange(of: extraReview) { _, newValue in
            if newValue.count > maxCharacters {
                extraReview = String(newValue.prefix(maxCharacters))
            }
        }
    }
}

#Preview("Collapsed") {
    @Previewable @State var text = ""
    ExtraReviewSection(extraReview: $text)
        .padding()
}

#Preview("Expanded Empty") {
    @Previewable @State var text = ""
    @Previewable @State var isExpanded = true

    VStack {
        ExtraReviewSection(extraReview: $text)
    }
    .padding()
    .onAppear {
        // Simulate expanded state
    }
}

#Preview("Expanded With Text") {
    @Previewable @State var text = "오티 했어용... 생각보다 과제가 많을 것 같아요."

    ExtraReviewSection(extraReview: $text)
        .padding()
}
