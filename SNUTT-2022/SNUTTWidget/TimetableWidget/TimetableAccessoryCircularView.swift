//
//  TimetableAccessoryCircularView.swift
//  SNUTTWidgetExtension
//
//  Created by 박신홍 on 2023/04/09.
//

import SwiftUI
import WidgetKit

struct TimetableAccessoryCircularView: View {
    var entry: SNUTTWidgetProvider.Entry

    var body: some View {
        if #available(iOS 16.0, *) {
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13)
                        .padding(.bottom, 3)
                    Group {
                        if let lectureTimes = entry.currentTimetable?.getRemainingLectureTimes(on: entry.date, by: .startTime),
                           let firstLectureTime = lectureTimes.get(at: 0)
                        {
                            Text(firstLectureTime.timePlace.startTime)
                        } else if isLoginRequired {
                            loginRequiredView
                        } else if isTimetableEmpty {
                            emptyTimetableView
                        } else {
                            emptyRemainingLecturesView
                        }
                    }
                    .font(.body.bold())
                }
            }
        }
    }
}

extension TimetableAccessoryCircularView: TimetableWidgetViewProtocol {
    var emptyTimetableView: some View {
        Text("-")
    }

    var emptyRemainingLecturesView: some View {
        Text("-")
    }

    var loginRequiredView: some View {
        Text("로그인")
    }
}
