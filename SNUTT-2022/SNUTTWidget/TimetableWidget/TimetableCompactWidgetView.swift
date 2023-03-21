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
                            TimePlaceListItem(lecture: item.lecture,
                                              timePlace: item.timePlace)
                        }

                        if let item = lectureTimes.get(at: 1) {
                            TimePlaceListItem(lecture: item.lecture,
                                              timePlace: item.timePlace,
                                              // show place string only if there's enough space available
                                              showPlace: lectureTimes.count <= 2 || lectureTimes.get(at: 0)?.timePlace.place.isEmpty == true)
                        }

                        if lectureTimes.count > 2 {
                            TimePlaceTruncatedItem(items: Array(lectureTimes.dropFirst(2)))
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

// TODO: circle 겹치게 +3

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
                            TimePlaceListItem(lecture: item.lecture,
                                              timePlace: item.timePlace,
                                              showPlace: false
                            )
                        }

                        TimePlaceTruncatedItem(items: Array(upcomingLectureTimesResult.lectureTimes.dropFirst(2)), showTime: true)
                    }
                }
            }
        }
        .padding(.top, 12)
    }
}

struct TimePlaceTruncatedItem: View {
    let items: [Timetable.LectureTime]
    var showTime: Bool = false

    var numberOfCircles: Int {
        min(items.count, 3)
    }

    var displayTitle: String {
        items.get(at: 0)?.lecture.title ?? "-"
    }

    var displayTime: String {
        guard let timePlace = items.get(at: 0)?.timePlace else { return "" }
        return "\(timePlace.startTime) - \(timePlace.endTime)"
    }

    var moreCount: Int {
        max(items.count - 1, 0)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ZStack {
                ForEach(0..<numberOfCircles, id: \.self) { index in
                    if let item = items.get(at: index) {
                        Circle()
                            .fill(item.lecture.getColor().bg)
                            .frame(width: 7, height: 7)
                            .overlay(
                                Circle()
                                    .stroke(STColor.systemBackground, lineWidth: 1)
                                    .frame(width: 8, height: 8)
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

                if showTime {
                    Text(displayTime)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
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

struct TimePlaceListItem: View {
    let lecture: Lecture
    let timePlace: TimePlace

    var showTime: Bool = true
    var showPlace: Bool = true


    var body: some View {
        HStack(alignment: .firstTextBaseline ,spacing: 0) {
            Circle()
                .fill(lecture.getColor().bg)
                .frame(width: 7, height: 7)

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
