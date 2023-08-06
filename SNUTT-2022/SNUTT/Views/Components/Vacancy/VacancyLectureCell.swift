//
//  VacancyLectureCell.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/22.
//

import SwiftUI

struct VacancyLectureCell: View {
    let lecture: Lecture

    var body: some View {
        VStack(spacing: 2) {
            // title
            titleView

            HStack {
                Spacer()
                Text("\(lecture.registrationCount?.description ?? "-")명 / \(lecture.quota)명")
                    .font(STFont.details)
                    .foregroundStyle(STColor.vacancyBlue)
            }
            .padding(.bottom, -7)

            VStack(spacing: 8) {
                // details
                LectureDetailRow(imageName: "tag.black", text: "\(lecture.department), \(lecture.academicYear)")
                LectureDetailRow(imageName: "clock.black", text: lecture.preciseTimeString)
                LectureDetailRow(imageName: "map.black", text: lecture.placesString)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
    }

    private var vacancyBadge: some View {
        Text("취소여석")
            .font(.system(size: 10))
            .padding(.vertical, 1)
            .padding(.horizontal, 3)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(STColor.vacancyRed, lineWidth: 1)
            )
            .foregroundColor(STColor.vacancyRed)
    }

    private var titleView: some View {
        HStack {
            Group {
                Text(lecture.title)
                    .font(STFont.subheading)
                    .lineLimit(1)
                if lecture.hasVacancy {
                    vacancyBadge
                }
                Spacer()
                if lecture.instructor.isEmpty {
                    Text("\(lecture.credit)학점")
                        .font(STFont.details)
                } else {
                    Text("\(lecture.instructor) / \(lecture.credit)학점")
                        .font(STFont.details)
                }
            }
        }
    }
}

#if DEBUG
    struct VacancyLectureCell_Previews: PreviewProvider {
        static var previewLecture: Lecture {
            var previewLecture = Lecture.preview
            return previewLecture
        }

        static var previews: some View {
            VStack {
                VacancyLectureCell(lecture: Self.previewLecture)
                    .border(.black.opacity(0.1), width: 1)
            }
        }
    }
#endif
