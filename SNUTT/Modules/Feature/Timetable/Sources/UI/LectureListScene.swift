//
//  LectureListScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SharedUIComponents

struct LectureListScene: View {
    let viewModel: TimetableViewModel
    var body: some View {
        ExpandableLectureListView(viewModel: LectureListViewModel(timetableViewModel: viewModel))
            .foregroundStyle(Color.label)
    }
}

#Preview {
    let viewModel = TimetableViewModel()
    let _ = Task {
        await viewModel.loadTimetable()
    }
    ZStack {
        LectureListScene(viewModel: viewModel)
    }
}
