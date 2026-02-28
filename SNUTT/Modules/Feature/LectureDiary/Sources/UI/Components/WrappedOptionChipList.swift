//
//  WrappedOptionChipList.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct WrappedOptionChipList: View {
    @Binding var selectedOptions: [AnswerOption]
    let answerOptions: [AnswerOption]
    let allowMultiple: Bool

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(answerOptions) { option in
                OptionChip(
                    label: option.content,
                    isSelected: selectedOptions.contains(option),
                    onTap: {
                        toggleOption(option)
                    }
                )
            }
        }
    }

    private func toggleOption(_ option: AnswerOption) {
        if allowMultiple {
            if selectedOptions.contains(option) {
                selectedOptions.removeAll { $0.id == option.id }
            } else {
                selectedOptions.append(option)
            }
        } else {
            selectedOptions = [option]
        }
    }
}

// Simple FlowLayout implementation
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY),
                proposal: .unspecified
            )
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview("Single Selection") {
    @Previewable @State var selected: [AnswerOption] = []

    let options = [
        AnswerOption(id: "1", content: "널널해요"),
        AnswerOption(id: "2", content: "무난해요"),
        AnswerOption(id: "3", content: "어려웠어요"),
    ]

    WrappedOptionChipList(
        selectedOptions: $selected,
        answerOptions: options,
        allowMultiple: false
    )
    .padding()
}

#Preview("Multiple Selection") {
    @Previewable @State var selected: [AnswerOption] = []

    let options = [
        AnswerOption(id: "1", content: "이론수업"),
        AnswerOption(id: "2", content: "토론수업"),
        AnswerOption(id: "3", content: "발표수업"),
        AnswerOption(id: "4", content: "실습수업"),
        AnswerOption(id: "5", content: "과제발표"),
        AnswerOption(id: "6", content: "퀴즈"),
    ]

    WrappedOptionChipList(
        selectedOptions: $selected,
        answerOptions: options,
        allowMultiple: true
    )
    .padding()
}
