//
//  LectureListCell.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/21.
//

import SwiftUI

struct LectureListCell: View {
    let lecture: Lecture

    @ViewBuilder
    func detailRow(imageName: String, text: String) -> some View {
        HStack {
            Image(imageName)
            Text(text)
                .font(STFont.details)
            Spacer()
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // title
            HStack {
                Text(lecture.title)
                    .font(STFont.subheading)
                Spacer()
                Text("\(lecture.instructor) / \(lecture.credit)학점")
                    .font(STFont.details)
            }

            // details
            if lecture.isCustom {
                detailRow(imageName: "tag.black", text: "(없음)")
            } else {
                detailRow(imageName: "tag.black", text: "\(lecture.department), \(lecture.academicYear)")
            }
            detailRow(imageName: "clock.black", text: "목2")
            detailRow(imageName: "map.black", text: "049-215")
        }
        .padding(.vertical, 5)

        let _ = debugChanges()
    }
}

struct TimetableListCell_Previews: PreviewProvider {
    static var previews: some View {
        LectureListCell(lecture: .preview)
    }
}
