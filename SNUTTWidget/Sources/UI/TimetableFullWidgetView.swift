//
//  TimetableFullWidgetView.swift
//  SNUTTWidgetExtension
//
//  Created by 박신홍 on 2023/03/18.
//

import SwiftUI
import TimetableInterface
import TimetableUIComponents

/// Just a simple wrapper of `TimetableWidgetView` for consistency.
struct TimetableFullWidgetView: View {
    var entry: TimelineProvider.Entry
    var body: some View {
        TimetableWidgetView(painter: entry.makeTimetablePainter())
    }
}
