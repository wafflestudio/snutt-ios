//
//  VacancyLectureCell.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/22.
//

import SwiftUI

struct VacancyLectureCell: View {
    let lecture: Lecture

    private enum Design {
        static let vacancyBlue: Color = .init(hex: "#446CC2")
        static let vacancyRed: Color = .init(hex: "#ED6C58")
        static let vacancyRedBackground: Color = vacancyRed.opacity(0.05)
    }

    private var hasVacancy: Bool {
        guard let current = lecture.registrationCount else { return false }
        return current < lecture.quota
    }

    var body: some View {
        VStack(spacing: 2) {
            // title
            titleView

            HStack {
                Spacer()
                Text("\(lecture.registrationCount?.description ?? "-")명 / \(lecture.quota)명")
                    .font(STFont.details)
                    .foregroundStyle(Design.vacancyBlue)
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
        .padding(.horizontal, 10)
        .background(hasVacancy ? Design.vacancyRedBackground : .clear)

        let _ = debugChanges()
    }

    private var vacancyBadge: some View {
        Text("취소여석")
            .font(.system(size: 10))
            .padding(.vertical, 1)
            .padding(.horizontal, 3)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Design.vacancyRed, lineWidth: 1)
            )
            .foregroundColor(Design.vacancyRed)
    }

    private var titleView: some View {
        HStack {
            Group {
                Text(lecture.title)
                    .font(STFont.subheading)
                vacancyBadge
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
            previewLecture.registrationCount = 179
            previewLecture.quota = 180
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
