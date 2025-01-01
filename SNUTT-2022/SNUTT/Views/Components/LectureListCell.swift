//
//  LectureListCell.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/21.
//

import SwiftUI

struct LectureListCell: View {
    let lecture: Lecture

    var body: some View {
        VStack(spacing: 8) {
            // title
            LectureHeaderRow(lecture: lecture)

            // details
            if lecture.isCustom {
                LectureDetailRow(imageName: "tag.black", text: "")
            } else {
                LectureDetailRow(imageName: "tag.black", text: "\(lecture.department), \(lecture.academicYear)")
            }
            LectureDetailRow(imageName: "clock.black", text: lecture.preciseTimeString)
            LectureDetailRow(imageName: "map.black", text: lecture.placesString)
        }
        .padding(.vertical, 5)

        let _ = debugChanges()
    }
}

struct LectureHeaderRow: View {
    let lecture: Lecture
    var body: some View {
        HStack {
            Group {
                Text(lecture.title)
                    .font(STFont.bold14.font)
                Spacer()
                if lecture.instructor.isEmpty {
                    Text("\(lecture.credit)학점")
                        .font(STFont.regular12.font)
                } else {
                    Text("\(lecture.instructor) / \(lecture.credit)학점")
                        .font(STFont.regular12.font)
                }
            }
        }
    }
}

struct LectureDetailRow: View {
    let imageName: String
    let text: String

    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .frame(width: 15, height: 15)
            Text(text.isEmpty ? "-" : text)
                .font(STFont.regular12.font)
                .lineLimit(1)
                .opacity(text.isEmpty ? 0.5 : 1)
            Spacer()
        }
    }
}

#if DEBUG
    struct TimetableListCell_Previews: PreviewProvider {
        static var previews: some View {
            LectureListCell(lecture: .preview)
        }
    }
#endif
