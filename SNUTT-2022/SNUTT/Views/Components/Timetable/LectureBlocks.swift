//
//  LectureBlocks.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/28.
//

import SwiftUI

struct LectureBlocks: View {
    typealias Painter = TimetableViewModel.TimetablePainter
    
    let lecture: Lecture
    @EnvironmentObject var timetableSetting: TimetableSetting
    
    var body: some View {
        GeometryReader { reader in
            ForEach(lecture.timePlaces) { timePlace in
                if let offsetPoint = Painter.getOffset(of: timePlace, in: reader.size, timetableSetting: timetableSetting) {
                    TimetableBlock(lecture: lecture, timePlace: timePlace)
                        .frame(width: Painter.getWeekWidth(in: reader.size, weekCount: timetableSetting.weekCount), height: Painter.getHeight(of: timePlace, in: reader.size, hourCount: timetableSetting.hourCount), alignment: .center)
                        .offset(x: offsetPoint.x, y: offsetPoint.y)
                }
            }
        }
    }
}

struct LectureBlocks_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TimetableViewModel(appState: AppState())
        LectureBlocks(lecture: viewModel.currentTimetable.lectures[0])
            .environmentObject(viewModel.timetableSetting)
    }
}
