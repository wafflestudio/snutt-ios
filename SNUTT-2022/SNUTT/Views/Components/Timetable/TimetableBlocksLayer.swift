//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlocksLayer: View {
    @EnvironmentObject var drawingSetting: TimetableSetting
    @EnvironmentObject var currentTimetable: Timetable
    
    var body: some View {
        GeometryReader { reader in
            ForEach(currentTimetable.lectures) { lecture in
                ForEach(lecture.timePlaces) { timePlace in
                    if let offsetPoint = TimetableViewModel.timetableDrawing.getOffset(of: timePlace, in: reader.size, drawingSetting: drawingSetting) {
                        TimetableBlock(lecture: lecture, timePlace: timePlace)
                            .frame(width: TimetableViewModel.timetableDrawing.getWeekWidth(in: reader.size, weekCount: drawingSetting.weekCount), height: TimetableViewModel.timetableDrawing.getHeight(of: timePlace, in: reader.size, hourCount: drawingSetting.hourCount), alignment: .center)
                            .offset(x: offsetPoint.x, y: offsetPoint.y)
                    }
                }
            }
        }
        
        let _ = debugChanges()
    }
}

struct TimetableBlocks_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            let viewModel = TimetableViewModel(appState: AppState())
            TimetableBlocksLayer()
                .environmentObject(viewModel.currentTimetable)
                .environmentObject(viewModel.drawingSetting)
            TimetableGridLayer()
        }
    }
}
