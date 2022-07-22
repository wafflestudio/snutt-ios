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
                LectureDetailRow(imageName: "tag.black", text: "(없음)")
            } else {
                LectureDetailRow(imageName: "tag.black", text: "\(lecture.department), \(lecture.academicYear)")
            }
            LectureDetailRow(imageName: "clock.black", text: lecture.timeString.isEmpty ? "(없음)" : lecture.timeString)
            LectureDetailRow(imageName: "map.black", text: lecture.timePlaces.isEmpty ? "(없음)" : lecture.timePlaces.map { $0.place}.joined(separator: "/"))
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
                    .font(STFont.subheading)
                Spacer()
                Text("\(lecture.instructor) / \(lecture.credit)학점")
                    .font(STFont.details)
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
                Text(text)
                    .font(STFont.details)
                Spacer()
            }
    }
}

struct TimetableListCell_Previews: PreviewProvider {
    static var previews: some View {
        LectureListCell(lecture: .preview)
    }
}
