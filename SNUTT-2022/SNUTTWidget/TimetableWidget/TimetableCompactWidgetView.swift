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
        ZStack {
            STColor.systemBackground
            HStack {
                TimetableCompactLeftView(entry: entry)

                if family == .systemMedium && !isTimetableEmpty && !isLoginRequired {
                    TimetableCompactRightView(entry: entry)
                        .padding(.leading, 5)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

extension TimetableCompactWidgetView: TimetableWidgetViewProtocol {
    var loginRequiredView: some View { EmptyView() }
    var emptyRemainingLecturesView: some View { EmptyView() }
    var emptyTimetableView: some View { EmptyView() }
}

struct TimetableCompactLeftView: View {
    var entry: SNUTTWidgetProvider.Entry

    var body: some View {
        VStack(spacing: 7) {
            dateHeaderView
            timetableBody
        }
        .padding(.top, 12)
    }

    private var dateHeaderView: some View {
        HStack {
            Text(entry.date.weekday.shortSymbol)
                .font(.system(size: 17, weight: .bold))
            Text(entry.date.localizedShortDateString)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.gray)
            Spacer()
        }
    }

    @MainActor private var timetableBody: some View {
        GeometryReader { reader in
            let lectureTimes = entry.currentTimetable?.getRemainingLectureTimes(on: entry.date, by: .endTime)
            if let lectureTimes, !lectureTimes.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    if let item = lectureTimes.get(at: 0) {
                        TimePlaceListItem(items: [item])
                    }

                    if let item = lectureTimes.get(at: 1) {
                        let hasEnoughSpace = lectureTimes.count <= 2 || lectureTimes.get(at: 0)?.timePlace.place.isEmpty == true
                        TimePlaceListItem(items: [item],
                                          showPlace: hasEnoughSpace)
                    }

                    if lectureTimes.count > 2 {
                        let hasEnoughSpace = lectureTimes.prefix(2).reduce(true) { partialResult, item in
                            partialResult && item.timePlace.place.isEmpty
                        }
                        TimePlaceListItem(items: Array(lectureTimes.dropFirst(2)), showTime: hasEnoughSpace, showPlace: false)
                    }
                    Spacer()
                }
                .frame(height: reader.size.height)
                .clipped()
            } else if isLoginRequired {
                loginRequiredView
            } else if isTimetableEmpty {
                emptyTimetableView
            } else {
                emptyRemainingLecturesView
            }
        }
    }
}

extension TimetableCompactLeftView: TimetableWidgetViewProtocol {
    var emptyTimetableView: some View {
        placeholderView(title: "빈 시간표", description: "시간표에 강의가 존재하지 않습니다.")
    }

    var loginRequiredView: some View {
        placeholderView(title: "로그인 필요", description: "먼저 로그인을 진행해주세요.")
    }

    var emptyRemainingLecturesView: some View {
        VStack {
            HStack(alignment: .center) {
                Circle()
                    .stroke(.gray.opacity(0.8), lineWidth: 1)
                    .frame(width: 6, height: 6)

                Text("오늘 남은 강의 없음")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    @ViewBuilder func placeholderView(title: String, description: String) -> some View {
        VStack {
            Spacer()
                .frame(height: 20)

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.bottom, 2)

            Text(description)
                .multilineTextAlignment(.center)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TimetableCompactRightView: View {
    var entry: SNUTTWidgetProvider.Entry
    var body: some View {
        VStack {
            GeometryReader { _ in
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

                        let remainingItems = Array(upcomingLectureTimesResult.lectureTimes.dropFirst(2))
                        if !remainingItems.isEmpty {
                            TimePlaceListItem(items: remainingItems, showPlace: false)
                        }
                    }
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

    @Environment(\.widgetFamily) private var family

    private var isAccessoryWidget: Bool {
        if #available(iOS 16.0, watchOS 9.0, *) {
            return family == .accessoryRectangular
        }
        return false
    }

    private var titleFontSize: CGFloat {
        isAccessoryWidget ? 15 : 13
    }

    private var secondaryFontSize: CGFloat {
        isAccessoryWidget ? 14 : 13
    }

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
                ForEach(0 ..< numberOfCircles, id: \.self) { index in
                    if let item = items.get(at: index) {
                        Circle()
                            .fill(item.lecture.getColor().bg)
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .stroke(STColor.systemBackground, lineWidth: 1)
                                    .opacity(isAccessoryWidget ? 0 : 1)
                            )
                            .offset(x: 5 * CGFloat(index))
                            .zIndex(-Double(index))
                    }
                }
            }

            Spacer()
                .frame(width: 8 + CGFloat(numberOfCircles - 1) * 3)

            VStack(alignment: .leading) {
                Text(displayTitle)
                    .font(.system(size: titleFontSize, weight: .semibold))
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
                .font(.system(size: titleFontSize, weight: .regular))
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
