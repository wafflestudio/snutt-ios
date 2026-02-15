//
//  LectureListScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import TimetableUIComponents

struct LectureListScene: View {
    let viewModel: TimetableViewModel
    var body: some View {
        let listViewModel = LectureListViewModel(timetableViewModel: viewModel)
        ExpandableLectureListView(viewModel: listViewModel)
            .foregroundStyle(Color.label)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        listViewModel.createNewLecture()
                    } label: {
                        Image(uiImage: TimetableAsset.navPlus.image)
                    }
                }
            }
            .analyticsScreen(.lectureList)
    }
}

#Preview {
    let viewModel = TimetableViewModel()
    let _ = Task {
        try await viewModel.loadTimetable()
    }
    ZStack {
        LectureListScene(viewModel: viewModel)
    }
}
