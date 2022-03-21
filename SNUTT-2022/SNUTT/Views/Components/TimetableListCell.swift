//
//  TimetableListCell.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/21.
//

import SwiftUI

extension Font {
    struct STFont {
        static let subheading: Font = .system(size: 15, weight: .bold)
        static let details: Font = .system(size: 12, weight: .regular)
    }
}

struct TimetableListCell: View {
    @ViewBuilder
    func detailRow(imageName: String, text: String) -> some View {
        HStack {
            Image(imageName)
            Text(text)
                .font(.STFont.details)
            Spacer()
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // title
            HStack {
                Text("편집디자인")
                    .font(.STFont.subheading)
                Spacer()
                Text("정희숙 / 3학점")
                    .font(.STFont.details)
            }

            // details
            detailRow(imageName: "tag.black", text: "디자인학부(디자인전공), 3학년")
            detailRow(imageName: "clock.black", text: "목2")
            detailRow(imageName: "map.black", text: "049-215")
        }.padding()
    }
}

struct TimetableListCell_Previews: PreviewProvider {
    static var previews: some View {
        TimetableListCell().previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
    }
}
