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

                Gauge(value: currentGaugeValue, in: 0...maximumGaugeValue) {
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
                .gaugeStyle(.accessoryCircularCapacity)
            }
        }
    }

    private var maximumGaugeValue: Double {
        guard let todayMidnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()),
              let count = entry.currentTimetable?.getRemainingLectureTimes(on: todayMidnight, by: .endTime).count,
              count > 0
        else { return Double.infinity }
        return Double(count)
    }

    private var currentGaugeValue: Double {
        guard let remainingCount = entry.currentTimetable?.getRemainingLectureTimes(on: Date(), by: .endTime).count else { return 0 }
        return maximumGaugeValue - Double(remainingCount)
    }


}

extension TimetableAccessoryCircularView: TimetableWidgetViewProtocol {
    var emptyTimetableView: some View {
        Text("-")
    }

    var emptyRemainingLecturesView: some View {
        Text("100%")
    }

    var loginRequiredView: some View {
        Text("로그인")
    }
}
