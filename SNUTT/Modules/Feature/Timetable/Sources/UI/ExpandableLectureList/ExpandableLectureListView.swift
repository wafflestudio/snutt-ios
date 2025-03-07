//
//  ExpandableLectureListView.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIIntrospect

struct ExpandableLectureListView: View {
    let viewModel: any ExpandableLectureListViewModel
    @State var scrolledID: String?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.lectures, id: \.id) { lecture in
                    ExpandableLectureCell(viewModel: viewModel, lecture: lecture)
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
        .scrollPosition(id: $scrolledID, anchor: .bottom)
        .onChange(of: scrolledID) { _, _ in
            if viewModel.lectures.suffix(5).map({ $0.id }).contains(scrolledID) {
                Task {
                    try await viewModel.fetchMoreLectures()
                }
            }
        }
        .introspect(.scrollView, on: .iOS(.v17, .v18)) { scrollView in
            scrollView.makeTouchResponsive()
        }
    }
}
