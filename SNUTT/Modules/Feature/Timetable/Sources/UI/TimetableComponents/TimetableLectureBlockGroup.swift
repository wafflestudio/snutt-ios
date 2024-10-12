//
//  TimetableLectureBlockGroup.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

struct TimetableLectureBlockGroup: View {
    @ObservedObject var viewModel: TimetableViewModel
    let lecture: any Lecture

    var body: some View {
        GeometryReader { reader in
            ForEach(lecture.timePlaces) { timePlace in
                if let offsetPoint = viewModel.getOffset(of: timePlace, in: reader.size) {
                    Group {
                        let blockHeight = viewModel.getHeight(of: timePlace, in: reader.size)
                        TimetableLectureBlock(lecture: lecture,
                                              timePlace: timePlace,
                                              idealHeight: blockHeight,
                                              visibilityOptions: viewModel.configuration.visibilityOptions)
                    }
                    .frame(width: viewModel.getWeekWidth(in: reader.size, weekCount: viewModel.weekCount),
                           height: viewModel.getHeight(of: timePlace, in: reader.size),
                           alignment: .top)
                    .clipped()
                    .offset(x: offsetPoint.x, y: offsetPoint.y)
                    .animation(.defaultSpring, value: viewModel.configuration.compactMode)
                }
            }
        }
    }
}

#Preview {
    let timetable: any Timetable = PreviewTimetable.preview
    let viewModel = {
        let viewModel = TimetableViewModel()
        viewModel.currentTimetable = timetable
        return viewModel
    }()
    TimetableLectureBlockGroup(viewModel: viewModel, lecture: timetable.lectures.first!)
}
