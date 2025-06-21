//
//  TimetableLectureBlockGroup.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SwiftUI
import TimetableInterface
import ThemesInterface

struct TimetableLectureBlockGroup: View {
    let painter: TimetablePainter
    let lecture: Lecture

    @Environment(\.lectureTapAction) var lectureTapAction

    var body: some View {
        GeometryReader { reader in
            ForEach(lecture.timePlaces) { timePlace in
                if let offsetPoint = painter.getOffset(of: timePlace, in: reader.size) {
                    Group {
                        let blockHeight = painter.getHeight(of: timePlace, in: reader.size)
                        Button {
                            lectureTapAction(lecture: lecture)
                        } label: {
                            TimetableLectureBlock(
                                lecture: lecture,
                                lectureColor: painter.resolveColor(for: lecture),
                                timePlace: timePlace,
                                idealHeight: blockHeight,
                                visibilityOptions: painter.configuration.visibilityOptions
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: painter.getWeekWidth(in: reader.size, weekCount: painter.weekCount),
                           height: painter.getHeight(of: timePlace, in: reader.size),
                           alignment: .top)
                    .clipped()
                    .offset(x: offsetPoint.x, y: offsetPoint.y)
                    .animation(.defaultSpring, value: painter.configuration.compactMode)
                    .allowsHitTesting(lectureTapAction.action != nil)
                }
            }
        }
    }
}

extension EnvironmentValues {
    @Entry public var lectureTapAction: LectureTapAction = .init(action: nil)
}

public struct LectureTapAction {
    public let action: ((Lecture) -> Void)?
    public init(action: ((Lecture) -> Void)?) {
        self.action = action
    }

    public func callAsFunction(lecture: Lecture) {
        action?(lecture)
    }
}

#Preview {
    let painter = makePreviewPainter()
    TimetableLectureBlockGroup(painter: painter, lecture: painter.currentTimetable!.lectures.first!)
}
