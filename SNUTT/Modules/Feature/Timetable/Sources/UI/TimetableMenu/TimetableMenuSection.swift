//
//  TimetableMenuSection.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

struct TimetableMenuSection<Content>: View where Content: View {
    let quarter: Quarter
    let current: Timetable?
    let isEmptyQuarter: Bool
    var content: () -> Content

    @State var isExpanded = false

    var body: some View {
        VStack {
            Button {
                withAnimation(.defaultSpring) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 5) {
                    Text(quarter.localizedDescription)
                        .font(.system(size: 16, weight: .semibold))

                    TimetableAsset.chevronRight.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0), anchor: .init(x: 0.75, y: 0.5))

                    if isEmptyQuarter {
                        CircleBadge(color: .red)
                            .padding(.leading, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 10) {
                    content()
                }
                .padding(.top, 5)
                .padding(.bottom, 15)
            }
        }
        .padding(.horizontal, 15)
        .frame(maxHeight: .infinity)
        .onAppear {
            // 새로운 학기와 현재 시간표가 속한 학기는 처음부터 확장되어 있도록 한다.
            isExpanded = (quarter == current?.quarter) || isEmptyQuarter
        }
        .onChange(of: current?.quarter) { _, newValue in
            // 현재 시간표가 속한 학기는 처음부터 확장되어 있도록 한다.
            if !isExpanded {
                withAnimation(.defaultSpring) {
                    isExpanded = quarter == newValue
                }
            }
        }
    }
}

extension Quarter {
    var localizedDescription: String {
        TimetableStrings.timetableQuarter(year, semester.localizedDescription)
    }
}

extension Semester {
    var localizedDescription: String {
        switch self {
        case .first:
            TimetableStrings.timetableSemester1
        case .summer:
            TimetableStrings.timetableSemesterSummer
        case .second:
            TimetableStrings.timetableSemester2
        case .winter:
            TimetableStrings.timetableSemesterWinter
        }
    }
}
