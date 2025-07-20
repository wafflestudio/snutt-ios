//
//  TimetableAccessoryRectangularView.swift
//  SNUTTWidgetExtension
//
//  Created by 박신홍 on 2023/04/05.
//

import SwiftUI
import TimetableUIComponents

struct TimetableAccessoryRectangularView: View {
    var entry: TimelineProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            if let lectureTimes = entry.currentTimetable?.getRemainingLectureTimes(on: entry.date, by: .startTime),
                let firstLectureTime = lectureTimes.get(at: 0)
            {
                TimePlaceListItem(items: [firstLectureTime], showTime: true, showPlace: true)
            } else if isLoginRequired {
                loginRequiredView
            } else if isTimetableEmpty {
                emptyTimetableView
            } else {
                emptyRemainingLecturesView
            }

            Spacer()
        }
        .padding(.horizontal, 1)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension TimetableAccessoryRectangularView: TimetableWidgetViewProtocol {
    var emptyRemainingLecturesView: some View {
        placeholderView(text: TimetableUIComponentsStrings.widgetNoRemainingLecturesToday)
    }

    var emptyTimetableView: some View {
        placeholderView(text: TimetableUIComponentsStrings.widgetEmptyTimetable)
    }

    var loginRequiredView: some View {
        placeholderView(text: TimetableUIComponentsStrings.widgetLoginRequired)
    }

    @ViewBuilder private func placeholderView(text: String) -> some View {
        VStack {
            HStack(alignment: .center) {
                Circle()
                    .stroke(.gray.opacity(0.8), lineWidth: 1)
                    .frame(width: 6, height: 6)

                Text(text)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
