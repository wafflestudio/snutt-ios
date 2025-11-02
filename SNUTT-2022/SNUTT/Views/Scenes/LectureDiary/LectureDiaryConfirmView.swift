//
//  LectureDiaryConfirmView.swift
//  SNUTT
//
//  Created by 최유림 on 4/26/25.
//

import SwiftUI

struct LectureDiaryConfirmView: View {
    
    let displayMode: DisplayMode
    let moveToReviewTab: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 24) {
                Image("heart.cat")
                VStack(spacing: 8) {
                    Text("강의일기가 등록되었습니다.")
                        .font(STFont.semibold15.font)
                        .foregroundStyle(.primary)
                    Text("작성한 강의일기는 더보기>강의일기장에서\n확인할 수 있어요.")
                        .lineHeight(with: STFont.regular13, percentage: 145)
                        .foregroundStyle(
                            colorScheme == .dark
                            ? STColor.gray30
                            : .primary.opacity(0.5)
                        )
                }
                .multilineTextAlignment(.center)
            }
            if displayMode != .reviewDone {
                Button {
                    displayMode == .reviewMore
                    // FIXME: add another review
                    ? moveToReviewTab()
                    : moveToReviewTab()
                } label: {
                    HStack(spacing: 4) {
                        Text(
                            displayMode == .reviewMore
                            ? "더 기록하기"
                            : "강의평 작성하기"
                        )
                        .font(STFont.regular15.font)
                        Image("daily.review.chevron.right")
                    }
                    .padding([.vertical, .trailing], 12)
                    .padding(.leading, 20)
                }
                .buttonBorderShape(.capsule)
                .foregroundStyle(.primary)
                .overlay(
                    Capsule().stroke(
                        colorScheme == .dark
                        ? STColor.gray30.opacity(0.4)
                        : STColor.border
                    )
                )
            }
            Spacer()
            RoundedRectButton(label: "홈으로", type: .medium, disabled: false) {
                print("button tapped")
            }
        }
        .padding(.top, 204)
        .padding(.bottom, 40)
        .padding(.horizontal, 32)
        .background(.white)
    }
}

extension LectureDiaryConfirmView {
    enum DisplayMode {
        case reviewMore
        case reviewDone
        case semesterEnd
    }
}

#Preview {
    LectureDiaryConfirmView(displayMode: .semesterEnd) {
        
    }
}
