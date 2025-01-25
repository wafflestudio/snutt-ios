//
//  LectureListScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct LectureListScene: View {
    let viewModel: TimetableViewModel
    var body: some View {
        ExpandableLectureListView(viewModel: LectureListViewModel(timetableViewModel: viewModel))
            .foregroundStyle(Color.label)
    }
}

#Preview {
    let viewModel = TimetableViewModel()
    _ = Task {
        await viewModel.loadTimetable()
    }
    ZStack {
        LectureListScene(viewModel: viewModel)
    }
}
