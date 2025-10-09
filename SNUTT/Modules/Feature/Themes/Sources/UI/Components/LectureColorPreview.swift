//
//  LectureColorPreview.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import ThemesInterface

struct LectureColorPreview: View {
    let lectureColor: LectureColor

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(lectureColor.fg)
                .border(Color.black.opacity(0.1), width: 0.5)
                .aspectRatio(1.0, contentMode: .fit)
            Rectangle()
                .fill(lectureColor.bg)
                .border(Color.black.opacity(0.1), width: 0.5)
                .aspectRatio(1.0, contentMode: .fit)
        }
    }
}
