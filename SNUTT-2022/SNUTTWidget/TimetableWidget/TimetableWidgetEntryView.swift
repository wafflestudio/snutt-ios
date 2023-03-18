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
        case .systemLarge:
            ZStack {
                STColor.systemBackground
                TimetableFullWidgetView(entry: entry)
            }
        default:
            ZStack {
                STColor.systemBackground
                TimetableCompactWidgetView(entry: entry)
            }
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
