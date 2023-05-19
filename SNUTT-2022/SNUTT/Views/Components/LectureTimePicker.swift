//
//  LectureTimePicker.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/11.
//

import SwiftUI

struct LectureTimePicker: View {
    @Binding var weekday: Weekday
    @Binding var start: Date
    @Binding var end: Date

    var startRange: ClosedRange<Date> {
        let calendar = Calendar.current
        return calendar.date(from: .init(hour: 0, minute: 0))! ... calendar.date(from: .init(hour: 23, minute: 50))!
    }

    var endRange: ClosedRange<Date> {
        let calendar = Calendar.current
        return calendar.date(byAdding: .minute, value: 5, to: start)! ... calendar.date(from: .init(hour: 23, minute: 59))!
    }

    /// Starting from iOS 16, the `Picker` design has changed.
    private var usePadding: Bool {
        if #available(iOS 16.0, *) {
            return false
        }
        return true
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("요일")
                Spacer()
                Picker("", selection: $weekday) {
                    ForEach(Weekday.allCases) { day in
                        Text(day.symbol).tag(day)
                    }
                }
                .labelsHidden()
                .padding(.horizontal, usePadding ? 12 : 0)
                .padding(.vertical, usePadding ? 3 : 0)
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color(uiColor: .tertiarySystemFill)))
            }

            Divider()
            DatePicker("시작",
                       selection: $start,
                       in: startRange,
                       displayedComponents: [.hourAndMinute])
                .datePickerStyle(.compact)
            Divider()
            DatePicker("종료",
                       selection: $end,
                       in: endRange,
                       displayedComponents: [.hourAndMinute])
                .datePickerStyle(.compact)
        }
        .padding()
        .onChange(of: start, perform: { _ in
            if !endRange.contains(end) {
                end = endRange.lowerBound
            }
        })
        .onAppear {
            UIDatePicker.appearance().minuteInterval = 5
        }
    }
}

struct LectureTimePicker_Previews: PreviewProvider {
    static var previews: some View {
        LectureTimePicker(weekday: .constant(.mon), start: .constant(Calendar.current.date(from: DateComponents(hour: 8))!), end: .constant(Calendar.current.date(from: DateComponents(hour: 15))!))
    }
}
