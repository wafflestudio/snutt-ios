//
//  LectureDetailListCell.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/23.
//

import SwiftUI

extension Font {
    static let contentLabel: Font = .system(size: 16)
    static let secondaryLabel: Font = .system(size: 14, weight: .regular)
}

extension Color {
    static let secondaryLabel: Color = Color(UIColor.secondaryLabel.withAlphaComponent(0.9))
}

struct LectureDetailListCell: View {
    let label: String
    let content: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.secondaryLabel)
                .foregroundColor(.secondaryLabel)
                .frame(minWidth: 70, alignment: .leading)
            Text(content)
                .font(.contentLabel)
            Spacer()
        }
    }
}

struct LectureDetailListCell_Previews: PreviewProvider {
    static var previews: some View {
        LectureDetailListCell(label: "강의명", content: "운영체제")
    }
}
