//
//  TimetableWidgetEntryView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/23.
//

import SwiftUI
import WidgetKit

struct TimetableWidgetEntryView: View {
    var entry: SNUTTWidgetProvider.Entry

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
            EmptyView()
        }
    }
}

protocol TimetableWidgetViewProtocol {
    associatedtype LoginRequiredView: View
    associatedtype EmptyTimetableView: View
    associatedtype EmptyRemainingLecturesView: View

    var entry: SNUTTWidgetProvider.Entry { get }

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
        guard let timetable = entry.currentTimetable else { return false /* isLoginRequired */ }
        return timetable.lectures.isEmpty
    }
}

#if DEBUG
    struct TimetableWidgetEntryView_Previews: PreviewProvider {
        static var previews: some View {
            TimetableWidgetEntryView(entry: TimetableEntry(date: Date(), configuration: ConfigurationIntent(), currentTimetable: .preview, timetableConfig: TimetableConfiguration()))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
#endif
