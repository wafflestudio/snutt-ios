//
//  ExpandableLectureListView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct ExpandableLectureListView: View {
    let viewModel: any ExpandableLectureListViewModel
    @State private var scrolledID: String?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.lectures, id: \.id) { lecture in
                    ExpandableLectureCell(viewModel: viewModel, lecture: lecture)
                        .highlightOnPress(precondition: viewModel.renderingOptions.contains(.scaleOnPress))
                    if viewModel.renderingOptions.contains(.showsDivider) {
                        Divider()
                            .frame(height: 1)
                            .padding(.leading, 10)
                            .padding(.top, 5)
                    }
                }
            }
            .scrollTargetLayout()
            .animation(.defaultSpring, value: viewModel.selectedLecture?.id)
        }
        .withResponsiveTouch()
        .scrollDismissesKeyboard(.interactively)
        .scrollPosition(id: $scrolledID, anchor: .bottom)
        .onAppear {
            scrolledID = viewModel.scrollPosition
        }
        .onChange(of: scrolledID) { _, _ in
            viewModel.scrollPosition = scrolledID
            if viewModel.lectures.suffix(5).map({ $0.id }).contains(scrolledID) {
                Task {
                    try await viewModel.fetchMoreLectures()
                }
            }
        }
    }
}
