//
//  EvaluationLectureDetailSortBar.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct EvaluationLectureDetailSortBar: View {
    var body: some View {
        VStack(spacing: 0) {
            Color(uiColor: .systemGray6)
                .frame(height: 12)

            HStack(spacing: 14) {
                EvaluationLectureDetailSortLabel(title: "추천순", isSelected: true)
                EvaluationLectureDetailSortLabel(title: "최신순", isSelected: false)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .frame(height: 52)
            .background(Color(uiColor: .systemBackground))
        }
    }
}

private struct EvaluationLectureDetailSortLabel: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(isSelected ? Color.primary : Color(uiColor: .systemGray3))
                .frame(width: 4, height: 4)

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isSelected ? Color.primary : Color(uiColor: .systemGray3))
        }
    }
}

#Preview {
    EvaluationLectureDetailSortBar()
}
