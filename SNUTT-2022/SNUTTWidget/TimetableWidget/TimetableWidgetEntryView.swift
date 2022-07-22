//
//  TimetableWidgetEntryView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/23.
//

import SwiftUI
import WidgetKit

struct TimetableWidgetEntryView: View {
    var entry: TimetableWidgetProvider.Entry
    
    var body: some View {
        Text("1212121")
    }
}

struct TimetableWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableWidgetEntryView(entry: TimetableEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

