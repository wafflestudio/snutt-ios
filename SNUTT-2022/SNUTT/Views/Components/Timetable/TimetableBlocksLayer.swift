//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlocksLayer: View {
    let drawing: TimetableViewModel.TimetableDrawing
    @EnvironmentObject var drawingSetting: AppState.DrawingSetting
    @EnvironmentObject var currentTimetable: AppState.CurrentTimetable
    
    var body: some View {
        GeometryReader { reader in
            ForEach(currentTimetable.lectures) { lecture in
                ForEach(lecture.timePlaces) { timePlace in
                    if let offsetPoint = drawing.getOffset(of: timePlace, in: reader.size, drawingSetting: drawingSetting) {
                        TimetableBlock(lecture: lecture, timePlace: timePlace)
                            .frame(width: drawing.getWeekWidth(in: reader.size, weekCount: drawingSetting.weekCount), height: drawing.getHeight(of: timePlace, in: reader.size, hourCount: drawingSetting.hourCount), alignment: .center)
                            .offset(x: offsetPoint.x, y: offsetPoint.y)
                    }
                }
            }
        }
        
        let _ = debugChanges()
    }
}
//
//struct TimetableBlocks_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            let viewModel = TimetableViewModel()
//            TimetableBlocksLayer(viewModel: viewModel)
//            TimetableGridLayer(viewModel: viewModel)
//        }
//    }
//}
