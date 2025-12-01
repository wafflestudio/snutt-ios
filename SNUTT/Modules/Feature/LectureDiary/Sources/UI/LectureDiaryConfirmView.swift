//
//  LectureDiaryConfirmView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct LectureDiaryConfirmView: View {
    @Environment(\.dismiss) private var dismiss

    let displayMode: DisplayMode

    public init(displayMode: DisplayMode) {
        self.displayMode = displayMode
    }

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundStyle(.pink)
                .padding(.bottom, 20)

            Text("강의일기가 등록되었습니다.")
                .font(.system(size: 15, weight: .semibold))
                .padding(.bottom, 8)

            Text("작성한 강의일기는 더보기>강의일기장\n에서 확인할 수 있어요.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.bottom, 40)

            if displayMode != .reviewDone {
                Button {
                    // TODO: Implement action based on displayMode
                    dismiss()
                } label: {
                    HStack {
                        Text(displayMode == .reviewMore ? "더 기록하기" : "강의평 작성하기")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 15))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .overlay(
                        Capsule()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.bottom, 20)
            }

            Spacer()

            Button("홈으로") {
                // TODO: Navigate to home
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
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
