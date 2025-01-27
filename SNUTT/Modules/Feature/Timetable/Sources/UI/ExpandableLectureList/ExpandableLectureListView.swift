//
//  ExpandableLectureListView.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct ExpandableLectureListView: View {
    let viewModel: any ExpandableLectureListViewModel
    @State var scrolledID: String?

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.lectures, id: \.id) { lecture in
                    ExpandableLectureCell(viewModel: viewModel, lecture: lecture)
                }
            }
            .scrollTargetLayout()
            .animation(.defaultSpring, value: viewModel.selectedLecture?.id)
        }
        .scrollPosition(id: $scrolledID, anchor: .bottom)
        .onChange(of: scrolledID) { _, newValue in
            let index = viewModel.lectures.firstIndex(where: { $0.id == newValue })
            if viewModel.lectures.suffix(5).map({ $0.id }).contains(scrolledID) {
                Task {
                    await viewModel.fetchMoreLectures()
                }
            }
        }
    }
}

#Preview {
    ExpandableLectureListView(viewModel: LectureSearchViewModel())
}
