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
        HStack {
            TimetableCompactLeftView(entry: entry)

            if family == .systemMedium {
                TimetableCompactRightView(entry: entry)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct TimetableCompactLeftView: View {
    var entry: SNUTTWidgetProvider.Entry

    var body: some View {
        VStack(spacing: 7) {
            HStack {
                Text(entry.date.weekday.shortSymbol)
                    .font(.system(size: 17, weight: .bold))

                Text(entry.date.localizedShortDateString)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)

                Spacer()
            }

            GeometryReader { reader in
                VStack(alignment: .leading, spacing: 5) {
                    if let lectureTimes = entry.currentTimetable?.getRemainingLectureTimes(on: entry.date) {

                        if let item = lectureTimes.get(at: 0) {
                            TimePlaceListItem(items: [item])
                        }

                        if let item = lectureTimes.get(at: 1) {
                            TimePlaceListItem(items: [item],
                                              showPlace: lectureTimes.count <= 2 || lectureTimes.get(at: 0)?.timePlace.place.isEmpty == true)
                        }

                        if lectureTimes.count > 2 {
                            TimePlaceListItem(items: Array(lectureTimes.dropFirst(2)), showTime: false, showPlace: false)
                        }

                    }

                    Spacer()

                }
                .frame(height: reader.size.height)
                .clipped()
            }

        }
        .padding(.top, 12)
    }
}

struct TimetableCompactRightView: View {
    var entry: SNUTTWidgetProvider.Entry
    var body: some View {
        VStack {
            GeometryReader { reader in
                if let upcomingLectureTimesResult = entry.currentTimetable?.getUpcomingLectureTimes()
                {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(upcomingLectureTimesResult.date.localizedDateString(dateStyle: .long, timeStyle: .none))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                            .lineLimit(1)

                        ForEach(upcomingLectureTimesResult.lectureTimes.prefix(2), id: \.timePlace.id) { item in
                            TimePlaceListItem(items: [item], showPlace: false)
                        }

                        TimePlaceListItem(items: Array(upcomingLectureTimesResult.lectureTimes.dropFirst(2)), showPlace: false)
                    }
                } else {
                    Text ("No upcoming ectures")
                }
            }
        }
        .padding(.top, 12)
    }
}

struct TimePlaceListItem: View {
    let items: [Timetable.LectureTime]

    var showTime: Bool = true
    var showPlace: Bool = true

    private var numberOfCircles: Int {
        min(items.count, 3)
    }

    private var displayItem: Timetable.LectureTime? {
        items.get(at: 0)
    }

    private var displayTitle: String {
        displayItem?.lecture.title ?? "-"
    }

    private var displayTime: String {
        guard let timePlace = displayItem?.timePlace else { return "" }
        return "\(timePlace.startTime) - \(timePlace.endTime)"
    }

    private var displayPlace: String? {
        guard let place = displayItem?.timePlace.place else { return nil }
        return place.isEmpty ? nil : place
    }

    private var moreCount: Int {
        max(items.count - 1, 0)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ZStack {
                ForEach(0..<numberOfCircles, id: \.self) { index in
                    if let item = items.get(at: index) {
                        Circle()
                            .fill(item.lecture.getColor().bg)
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .stroke(STColor.systemBackground, lineWidth: 1)
                            )
                            .offset(x: 5 * CGFloat(index))
                            .zIndex(-Double(index))
                    }
                }
            }

            Spacer()
                .frame(width: 10 + CGFloat(numberOfCircles - 1) * 2.5)

            VStack(alignment: .leading) {
                Text(displayTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                Group {
                    if showTime {
                        Text(displayTime)
                    }

                    if let place = displayPlace, showPlace {
                        Text("\(place)")
                    }
                }
                .lineLimit(1)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.gray)
            }



            if moreCount > 0 {
                Spacer()
                Text("+\(moreCount)")
                    .padding(.trailing, 15)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

        }
    }

}

#if DEBUG
struct TimetableCompactWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableCompactWidgetView(entry: .init(date: Calendar.current.date(from: .init(hour: 0, minute: 0))!, configuration: ConfigurationIntent(), currentTimetable: .preview, timetableConfig: .init()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
