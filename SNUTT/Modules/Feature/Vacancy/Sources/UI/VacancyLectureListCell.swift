//
//  VacancyLectureListCell.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import SwiftUI
import TimetableInterface

public struct VacancyLectureListCell: View {
    let lecture: Lecture
    @Environment(\.timetableUIProvider) private var timetableUIProvider
    @Environment(\.editMode) private var editMode

    public init(lecture: Lecture) {
        self.lecture = lecture
    }

    private enum Design {
        static let vacancyBlue: Color = .init(hex: "#446CC2")
        static let vacancyRed: Color = .init(hex: "#ED6C58")
        static let vacancyRedBackground: Color = vacancyRed.opacity(0.05)
    }

    public var body: some View {
        VStack(spacing: 2) {
            titleView

            HStack {
                Spacer()
                Text(
                    "\(lecture.registrationCount)\(VacancyStrings.peopleCountUnit) / \(lecture.quota ?? 0)\(VacancyStrings.peopleCountUnit)"
                )
                .font(.system(size: 12))
                .foregroundStyle(Design.vacancyBlue)
            }
            .padding(.bottom, -7)

            VStack(spacing: 8) {
                timetableUIProvider.lectureDetailRow(type: .department, lecture: lecture)
                timetableUIProvider.lectureDetailRow(type: .time, lecture: lecture)
                timetableUIProvider.lectureDetailRow(type: .place, lecture: lecture)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .listRowInsets(EdgeInsets())
        .listRowBackground(lecture.hasVacancy ? Design.vacancyRedBackground : .clear)
    }

    private var vacancyBadge: some View {
        Text(VacancyStrings.cancellationVacancy)
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
                Text(lecture.courseTitle)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(1)
                if lecture.hasVacancy {
                    vacancyBadge
                }
                Spacer()
                if let instructor = lecture.instructor,
                    let credit = lecture.credit
                {
                    Text("\(instructor) / \(credit)\(VacancyStrings.creditUnit)")
                        .font(.system(size: 12))
                } else {
                    Text("\(lecture.credit ?? 0)\(VacancyStrings.creditUnit)")
                        .font(.system(size: 12))
                }
            }
        }
    }
}

extension Lecture {
    var hasVacancy: Bool {
        guard let quota else { return false }
        return wasFull && registrationCount < quota
    }
}

#Preview {
    VacancyLectureListCell(lecture: PreviewHelpers.preview.lectures.first!)
}
