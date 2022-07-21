//
//  LectureListCell.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/21.
//

import SwiftUI

struct LectureListCell: View {
    let lecture: Lecture
    var colorMode: ColorMode = .automatic
    
    enum ColorMode {
        case automatic, white
        
        var imageColorVariant: String {
            switch self {
            case .automatic:
                return "black"
            case .white:
                return "white"
            }
        }
        
        var fontColor: Color {
            switch self {
            case .automatic:
                return Color(uiColor: .label)
            case .white:
                return .white
            }
        }
    }

    @ViewBuilder
    func detailRow(imageName: String, text: String) -> some View {
        HStack {
            Image(imageName)
            Text(text)
                .font(STFont.details)
                .foregroundColor(colorMode.fontColor)
            Spacer()
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // title
            HStack {
                Group {
                    Text(lecture.title)
                        .font(STFont.subheading)
                    Spacer()
                    Text("\(lecture.instructor) / \(lecture.credit)학점")
                        .font(STFont.details)
                }
                .foregroundColor(colorMode.fontColor)
            }

            // details
            if lecture.isCustom {
                detailRow(imageName: "tag.\(colorMode.imageColorVariant)", text: "(없음)")
            } else {
                detailRow(imageName: "tag.\(colorMode.imageColorVariant)", text: "\(lecture.department), \(lecture.academicYear)")
            }
            detailRow(imageName: "clock.\(colorMode.imageColorVariant)", text: lecture.timeString.isEmpty ? "(없음)" : lecture.timeString)
            detailRow(imageName: "map.\(colorMode.imageColorVariant)", text: lecture.timePlaces.isEmpty ? "(없음)" : lecture.timePlaces.map { $0.place}.joined(separator: "/"))
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
