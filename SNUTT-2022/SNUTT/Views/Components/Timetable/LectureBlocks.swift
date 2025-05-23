//
//  LectureBlocks.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/28.
//

import SwiftUI

struct LectureBlocks: View {
    typealias Painter = TimetablePainter
    let current: Timetable?
    let lecture: Lecture
    let theme: Theme?
    let config: TimetableConfiguration

    #if !WIDGET
        @Environment(\.dependencyContainer) var container: DIContainer?
    #endif

    var body: some View {
        GeometryReader { reader in
            ForEach(lecture.timePlaces) { timePlace in
                if let offsetPoint = Painter.getOffset(of: timePlace,
                                                       in: reader.size,
                                                       current: current,
                                                       config: config)
                {
                    Group {
                        let blockHeight = Painter.getHeight(
                            of: timePlace,
                            in: reader.size,
                            current: current,
                            config: config
                        )
                        #if WIDGET
                            TimetableBlock(lecture: lecture,
                                           timePlace: timePlace,
                                           theme: theme,
                                           idealHeight: blockHeight,
                                           visibilityOptions: config.visibilityOptions)
                        #else
                            if let container = container {
                                NavigationLink(destination: LectureDetailScene(
                                    viewModel: .init(container: container),
                                    lecture: lecture,
                                    displayMode: .normal
                                ).analyticsScreen(.lectureDetail(.init(
                                    lectureID: lecture.referenceId,
                                    referrer: .timetable
                                )))) {
                                    TimetableBlock(lecture: lecture,
                                                   timePlace: timePlace,
                                                   theme: theme,
                                                   idealHeight: blockHeight,
                                                   visibilityOptions: config.visibilityOptions)
                                }
                                .buttonStyle(.plain)
                            } else {
                                TimetableBlock(lecture: lecture,
                                               timePlace: timePlace,
                                               theme: theme,
                                               idealHeight: blockHeight,
                                               visibilityOptions: config.visibilityOptions)
                            }
                        #endif
                    }
                    .frame(
                        width: Painter.getWeekWidth(
                            in: reader.size,
                            weekCount: Painter.getWeekCount(current: current, config: config)
                        ),
                        height: Painter.getHeight(of: timePlace, in: reader.size, current: current, config: config),
                        alignment: .top
                    )
                    .clipped()
                    .offset(x: offsetPoint.x, y: offsetPoint.y)
                    .animation(.customSpring, value: config.compactMode)
                }
            }
        }
        let _ = debugChanges()
    }
}

// struct LectureBlocks_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewModel = TimetableViewModel(container: .preview)
//        LectureBlocks(viewModel: .init(container: .preview), lecture: .preview)
//            .environmentObject(viewModel.timetableState)
//    }
// }
