//
//  TimetableZStack.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

public struct TimetableZStack: View {
    let painter: any TimetablePainter

    public init(painter: any TimetablePainter) {
        self.painter = painter
    }

    public var body: some View {
        ZStack {
            TimetableGridLayer(painter: painter)
            TimetableBlocksLayer(painter: painter)
        }
    }
}

// MARK: Preview

struct PreviewPainter: TimetablePainter {
    var currentTimetable: (any TimetableInterface.Timetable)?
    var selectedLecture: (any TimetableInterface.Lecture)?
    let configuration: TimetableConfiguration
}

@MainActor func makePreviewPainter() -> PreviewPainter {
    let timetable: any Timetable = PreviewHelpers.preview(with: "1")
    var painter = PreviewPainter(configuration: TimetableConfiguration())
    painter.currentTimetable = timetable
    painter.selectedLecture = timetable.lectures.first
    return painter
}

#Preview {
    TimetableZStack(painter: makePreviewPainter())
}
