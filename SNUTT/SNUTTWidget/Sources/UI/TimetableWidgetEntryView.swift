//
//  TimetableWidgetEntryView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/23.
//

import SwiftUI
import WidgetKit

struct TimetableWidgetEntryView: View {
    var entry: TimelineProvider.Entry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemLarge, .systemExtraLarge:
            TimetableFullWidgetView(entry: entry)
        case .systemSmall, .systemMedium:
            TimetableCompactWidgetView(entry: entry)
        case .accessoryRectangular:
            TimetableAccessoryRectangularView(entry: entry)
        case .accessoryInline:
            TimetableAccessoryInlineView(entry: entry)
        case .accessoryCircular:
            TimetableAccessoryCircularView(entry: entry)
        default:
            Text("\(family) is not supported")
        }
    }
}

protocol TimetableWidgetViewProtocol {
    associatedtype LoginRequiredView: View
    associatedtype EmptyTimetableView: View
    associatedtype EmptyRemainingLecturesView: View
    var entry: TimelineProvider.Entry { get }
    var isLoginRequired: Bool { get }
    var isTimetableEmpty: Bool { get }

    @ViewBuilder @MainActor var loginRequiredView: LoginRequiredView { get }
    @ViewBuilder @MainActor var emptyTimetableView: EmptyTimetableView { get }
    @ViewBuilder @MainActor var emptyRemainingLecturesView: EmptyRemainingLecturesView { get }
}

extension TimetableWidgetViewProtocol {
    var isLoginRequired: Bool {
        entry.currentTimetable == nil
    }

    var isTimetableEmpty: Bool {
        guard let timetable = entry.currentTimetable else { return false }
        return timetable.lectures.isEmpty
    }
}
