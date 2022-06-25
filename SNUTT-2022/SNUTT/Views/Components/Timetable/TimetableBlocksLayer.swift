//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlocksLayer: View {
    typealias Painter = TimetableViewModel.TimetablePainter
    @ObservedObject var drawingSetting = AppState.of.timetableSetting
    @ObservedObject var currentTimetable = AppState.of.currentTimetable

    var body: some View {
        GeometryReader { reader in
            ForEach(currentTimetable.lectures) { lecture in
                ForEach(lecture.timePlaces) { timePlace in
                    if let offsetPoint = Painter.getOffset(of: timePlace, in: reader.size, drawingSetting: drawingSetting) {
                        TimetableBlock(lecture: lecture, timePlace: timePlace)
                            .frame(width: Painter.getWeekWidth(in: reader.size, weekCount: drawingSetting.weekCount), height: Painter.getHeight(of: timePlace, in: reader.size, hourCount: drawingSetting.hourCount), alignment: .center)
                            .offset(x: offsetPoint.x, y: offsetPoint.y)
                    }
                }
            }
        }

        let _ = debugChanges()
    }
}

//
// struct TimetableBlocks_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            let viewModel = TimetableViewModel()
//            TimetableBlocksLayer(viewModel: viewModel)
//            TimetableGridLayer(viewModel: viewModel)
//        }
//    }
// }
