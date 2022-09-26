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

    var config: TimetableConfiguration = {
        var config = TimetableConfiguration()
        config.maxHour = 18
        return config
    }()

    var body: some View {
        ZStack {
            STColor.systemBackground
            TimetableZStack(current: entry.currentTimetable, config: config)
        }
    }
}

#if DEBUG
struct TimetableWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableWidgetEntryView(entry: TimetableEntry(date: Date(), configuration: ConfigurationIntent(), currentTimetable: .preview))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
