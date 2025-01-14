//
//  TimetableLectureBlockGroup.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

struct TimetableLectureBlockGroup: View {
    let painter: any TimetablePainter
    let lecture: any Lecture

    var body: some View {
        GeometryReader { reader in
            ForEach(lecture.timePlaces) { timePlace in
                if let offsetPoint = painter.getOffset(of: timePlace, in: reader.size) {
                    Group {
                        let blockHeight = painter.getHeight(of: timePlace, in: reader.size)
                        TimetableLectureBlock(lecture: lecture,
                                              timePlace: timePlace,
                                              idealHeight: blockHeight,
                                              visibilityOptions: painter.configuration.visibilityOptions)
                    }
                    .frame(width: painter.getWeekWidth(in: reader.size, weekCount: painter.weekCount),
                           height: painter.getHeight(of: timePlace, in: reader.size),
                           alignment: .top)
                    .clipped()
                    .offset(x: offsetPoint.x, y: offsetPoint.y)
                    .animation(.defaultSpring, value: painter.configuration.compactMode)
                }
            }
        }
    }
}

#Preview {
    let painter = makePreviewPainter()
    TimetableLectureBlockGroup(painter: painter, lecture: painter.currentTimetable!.lectures.first!)
}
