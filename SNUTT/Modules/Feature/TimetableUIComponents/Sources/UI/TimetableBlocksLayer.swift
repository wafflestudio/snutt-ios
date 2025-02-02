//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

struct TimetableBlocksLayer: View {
    let painter: TimetablePainter

    var body: some View {
        ForEach(painter.currentTimetable?.lectures ?? [], id: \.id) { lecture in
            TimetableLectureBlockGroup(painter: painter, lecture: lecture)
        }

        if let selectedLecture = painter.selectedLecture {
            TimetableLectureBlockGroup(painter: painter, lecture: selectedLecture)
        }
    }
}

#Preview {
    TimetableBlocksLayer(painter: makePreviewPainter())
}
