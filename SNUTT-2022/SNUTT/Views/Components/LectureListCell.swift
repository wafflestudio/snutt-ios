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
                Text("정희숙 / 3학점")
                    .font(STFont.details)
            }

            // details
            detailRow(imageName: "tag.black", text: "디자인학부(디자인전공), 3학년")
            detailRow(imageName: "clock.black", text: "목2")
            detailRow(imageName: "map.black", text: "049-215")
        }
        .padding(.vertical, 5)

        let _ = debugChanges()
    }
}

//struct TimetableListCell_Previews: PreviewProvider {
//    static var previews: some View {
//        let lecture = Lecture(id: 1, title: "컴파일러", instructor: "전병곤", timePlaces: [
//            TimePlace(day: Weekday(rawValue: 1)!, start: 5.5, len: 1.5, place: "302-123"),
//            TimePlace(day: Weekday(rawValue: 3)!, start: 3.15, len: 1.5, place: "302-123"),
//            TimePlace(day: Weekday(rawValue: 3)!, start: 4.70, len: 1.5, place: "302-123"),
//        ])
//
//        LectureListCell(lecture: lecture)
//    }
//}
