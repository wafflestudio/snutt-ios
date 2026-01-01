//
//  TimetableLectureBlockGroup.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SwiftUI
import ThemesInterface
import TimetableInterface

struct TimetableLectureBlockGroup: View {
    let painter: TimetablePainter
    let lecture: Lecture
    let geometry: TimetableGeometry

    @Environment(\.lectureTapAction) var lectureTapAction

    var body: some View {
        GeometryReader { _ in
            ForEach(lecture.timePlaces) { timePlace in
                if let offsetPoint = painter.getOffset(of: timePlace, in: geometry.size) {
                    Button {
                        lectureTapAction(lecture: lecture)
                    } label: {
                        TimetableLectureBlock(
                            lecture: lecture,
                            lectureColor: painter.resolveColor(for: lecture),
                            timePlace: timePlace,
                            idealHeight: painter.getHeight(of: timePlace, in: geometry.size),
                            visibilityOptions: painter.configuration.visibilityOptions
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(
                        width: painter.getWeekWidth(in: geometry.size),
                        height: painter.getHeight(of: timePlace, in: geometry.size),
                        alignment: .top
                    )
                    .clipped()
                    .offset(x: offsetPoint.x, y: offsetPoint.y)
                    .animation(.defaultSpring, value: painter.configuration.compactMode)
                    .allowsHitTesting(lectureTapAction.action != nil)
                }
            }
        }
    }
}
