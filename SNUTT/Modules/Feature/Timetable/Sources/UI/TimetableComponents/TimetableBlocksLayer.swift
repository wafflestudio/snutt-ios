//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

struct TimetableBlocksLayer: View {
    @ObservedObject var viewModel: TimetableViewModel

    var body: some View {
        ForEach(viewModel.currentTimetable?.lectures ?? [], id: \.id) { lecture in
            TimetableLectureBlockGroup(viewModel: viewModel, lecture: lecture)
        }

        if let selectedLecture = viewModel.selectedLecture {
            TimetableLectureBlockGroup(viewModel: viewModel, lecture: selectedLecture)
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
    TimetableBlocksLayer(viewModel: viewModel)
}
