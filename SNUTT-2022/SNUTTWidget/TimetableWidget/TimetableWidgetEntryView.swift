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
            ZStack {
                STColor.systemBackground
                TimetableFullWidgetView(entry: entry)
            }
        case .systemSmall, .systemMedium:
            ZStack {
                STColor.systemBackground
                TimetableCompactWidgetView(entry: entry)
            }
        default:
            EmptyView()
        }
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
