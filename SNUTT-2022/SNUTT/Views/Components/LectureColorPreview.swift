//
//  LectureColorPreview.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/29.
//

import SwiftUI

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

struct LectureColorPreview_Previews: PreviewProvider {
    static var previews: some View {
        LectureColorPreview(lectureColor: .init(fg: .white, bg: .blue))
            .frame(height: 50)
    }
}
