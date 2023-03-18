//
//  TimetableCompactWidgetView.swift
//  SNUTTWidgetExtension
//
//  Created by 박신홍 on 2023/03/18.
//

import SwiftUI
import WidgetKit

struct TimetableCompactWidgetView: View {
    var entry: SNUTTWidgetProvider.Entry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(entry.date.weekday.shortSymbol)
                    .font(.system(size: 17, weight: .bold))

                Text(entry.date.localizedDateString)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)

                Spacer()
            }

            GeometryReader { reader in
                VStack(spacing: 5) {
                    if let timetable = entry.currentTimetable,
                       let lectureTimes = timetable.getRemainingLectureTimes(on: entry.date) {

                        if let item = lectureTimes.get(at: 0) {
                            TimePlaceListItem(timetable: timetable,
                                              lecture: item.lecture,
                                              timePlace: item.timePlace)
                        }

                        if let item = lectureTimes.get(at: 1) {
                            TimePlaceListItem(timetable: timetable,
                                              lecture: item.lecture,
                                              timePlace: item.timePlace,
                                              // show place string only if there's enough space available
                                              showPlace: lectureTimes.count <= 2 || lectureTimes.get(at: 0)?.timePlace.place.isEmpty == true)
                        }

                        if let item = lectureTimes.get(at: 2) {
                            TimePlaceListItem(timetable: timetable,
                                              lecture: item.lecture,
                                              timePlace: item.timePlace,
                                              showTime: false,
                                              showPlace: false)
                        }
                    }
                }
                .frame(height: reader.size.height)
                .clipped()
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)

    }
}

struct TimePlaceListItem: View {
    let timetable: Timetable
    let lecture: Lecture
    let timePlace: TimePlace

    var showTime: Bool = true
    var showPlace: Bool = true


    var body: some View {
        HStack(alignment: .firstTextBaseline ,spacing: 0) {
            Circle()
                .frame(width: 7, height: 7)
                .foregroundColor(lecture.getColor().bg)

            Spacer()
                .frame(width: 10)

            VStack(alignment: .leading) {
                Text(lecture.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                Group {
                    if showTime {
                        Text("\(timePlace.startTime) - \(timePlace.endTime)")
                    }

                    if showPlace && !timePlace.place.isEmpty {
                        Text("\(timePlace.place)")
                    }
                }
                .lineLimit(1)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

#if DEBUG
struct TimetableCompactWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableCompactWidgetView(entry: .init(date: Date(), configuration: ConfigurationIntent(), currentTimetable: .preview, timetableConfig: .init()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
#endif
