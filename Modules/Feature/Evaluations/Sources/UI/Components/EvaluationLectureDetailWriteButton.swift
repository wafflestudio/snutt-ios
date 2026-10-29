//
//  EvaluationLectureDetailWriteButton.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct EvaluationLectureDetailWriteButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "pencil")
                    .font(.system(size: 19, weight: .bold))

                Text("강의평 작성")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .frame(height: 52)
            .background(EvaluationDesignColor.mint)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 6, y: 2)
        }
        .buttonStyle(.animatable(scale: 0.98))
    }
}

#Preview {
    EvaluationLectureDetailWriteButton(action: {})
}
