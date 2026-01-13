//
//  LectureDiaryConfirmView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

public struct LectureDiaryConfirmView: View {
    @Environment(\.dismiss) private var dismiss

    let displayMode: DisplayMode

    public init(displayMode: DisplayMode) {
        self.displayMode = displayMode
    }

    public var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 24) {
                SharedUIComponentsAsset.catHeart.swiftUIImage

                VStack(spacing: 8) {
                    Text(LectureDiaryStrings.lectureDiaryConfirmTitle)
                        .font(.system(size: 15, weight: .semibold))

                    Text(LectureDiaryStrings.lectureDiaryConfirmSubtitle)
                        .lineHeight(with: .systemFont(ofSize: 13), percentage: 145)
                        .foregroundStyle(
                            light: .primary.opacity(0.5),
                            dark: SharedUIComponentsAsset.gray30.swiftUIColor
                        )
                }
                .multilineTextAlignment(.center)
            }

            if displayMode != .reviewDone {
                Button {
                    // TODO: Implement action based on displayMode
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Text(
                            displayMode == .reviewMore
                                ? LectureDiaryStrings.lectureDiaryConfirmReviewMore
                                : LectureDiaryStrings.lectureDiaryConfirmReviewEval
                        )
                        LectureDiaryAsset.chevronRight.swiftUIImage
                    }
                    .font(.system(size: 15))
                    .padding(.leading, 20)
                    .padding([.vertical, .trailing], 12)
                    .overlayCapsuleStyle(
                        light: SharedUIComponentsAsset.border.swiftUIColor,
                        dark: SharedUIComponentsAsset.gray30.swiftUIColor.opacity(0.4)
                    )
                }
                .padding(.bottom, 20)
            }
            Spacer()
            Button(
                LectureDiaryStrings.lectureDiaryConfirmHome
            ) {
                // TODO: Navigate to home
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .padding(.top, 204)
        .padding(.bottom, 40)
        .padding(.horizontal, 32)
        .backgroundStyle(
            light: .white,
            dark: SharedUIComponentsAsset.neutral5.swiftUIColor
        )
    }
}

extension LectureDiaryConfirmView {
    public enum DisplayMode {
        case reviewMore  // 더 기록하기 버튼 표시
        case reviewDone  // 버튼 없이 완료만 표시
        case semesterEnd  // 강의평 작성하기 버튼 표시
    }
}

#Preview("Review More") {
    LectureDiaryConfirmView(displayMode: .reviewMore)
}

#Preview("Review Done") {
    LectureDiaryConfirmView(displayMode: .reviewDone)
}

#Preview("Semester End") {
    LectureDiaryConfirmView(displayMode: .semesterEnd)
}
