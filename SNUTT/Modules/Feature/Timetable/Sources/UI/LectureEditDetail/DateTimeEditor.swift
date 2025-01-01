//
//  DateTimeEditor.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface
import FoundationUtility
import SwiftUIUtility
import SharedUIComponents

struct DateTimeEditor: View {
    @Environment(LectureEditDetailViewModel.self) private var viewModel
    @Binding var timePlace: TimePlace

    init(timePlace: Binding<TimePlace>) {
        _timePlace = timePlace
        _temporaryTimePlace = .init(initialValue: timePlace.wrappedValue)
    }

    @State private var temporaryTimePlace: TimePlace
    @State private var isPickerPresented = false


    var body: some View {
        Text("\(timePlace.day.shortSymbol) \(timePlace.startTime.description) ~ \(timePlace.endTime.description)")
            .onTapGesture {
                isPickerPresented = true
            }
            .highlightOnPress()
            .frame(maxWidth: .infinity, alignment: .leading)
            .sheet(isPresented: $isPickerPresented) {
                pickerSheetContent
            }
    }

    private var pickerSheetContent: some View {
        VStack {
            SheetTopBar {
                temporaryTimePlace = timePlace
                isPickerPresented = false
            } confirm: {
                timePlace = temporaryTimePlace
                isPickerPresented = false
            }
            LectureTimePicker(
                weekday: $temporaryTimePlace.day,
                startTime: $temporaryTimePlace.startTime,
                endTime: $temporaryTimePlace.endTime
            )
            .padding()
            Spacer()
        }
        .ignoresSafeArea()
        .presentationDetents([.height(250)])
    }
}

private struct LectureTimePicker: View {
    private let calendar = Calendar.current

    @Binding var weekday: Weekday
    @Binding var startTime: Time
    @Binding var endTime: Time

    private var start: Binding<Date> {
        .init(
            get: { startTime.toDate(from: calendar) },
            set: { startTime = $0.toTime(from: calendar) }
        )
    }

    private var end: Binding<Date> {
        .init(
            get: { endTime.toDate(from: calendar) },
            set: { endTime = $0.toTime(from: calendar) }
        )
    }

    var startRange: ClosedRange<Date> {
        let calendar = Calendar.current
        return calendar.date(from: .init(hour: 0, minute: 0))! ... calendar.date(from: .init(hour: 23, minute: 50))!
    }

    var endRange: ClosedRange<Date> {
        let calendar = Calendar.current
        return calendar.date(byAdding: .minute, value: 5, to: start.wrappedValue)! ... calendar.date(from: .init(hour: 23, minute: 59))!
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
                .tint(.label)
                .labelsHidden()
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color(uiColor: .tertiarySystemFill)))
            }

            Divider()
            DatePicker("시작",
                       selection: start,
                       in: startRange,
                       displayedComponents: [.hourAndMinute])
                .datePickerStyle(.compact)
                .introspect(.datePicker, on: .iOS(.v17, .v18)) { datePicker in
                    datePicker.minuteInterval = 5
                }
            Divider()
            DatePicker("종료",
                       selection: end,
                       in: endRange,
                       displayedComponents: [.hourAndMinute])
                .datePickerStyle(.compact)
                .introspect(.datePicker, on: .iOS(.v17, .v18)) { datePicker in
                    datePicker.minuteInterval = 5
                }
        }
        .onChange(of: startTime, { oldValue, newValue in
            if !endRange.contains(end.wrappedValue) {
                end.wrappedValue = endRange.lowerBound
            }
        })
    }
}

extension Time {
    fileprivate func toDate(from calendar: Calendar) -> Date {
        calendar.date(from: .init(hour: hour, minute: minute)) ?? .distantPast
    }
}

extension Date {
    fileprivate func toTime(from calendar: Calendar) -> Time {
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        return .init(hour: hour, minute: minute)
    }
}
