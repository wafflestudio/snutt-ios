//
//  TimetableMenuContent.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SharedUIComponents
import TimetableInterface

struct TimetableMenuContentView: View {
    private let viewModel: TimetableMenuViewModel
    init(timetableViewModel: TimetableViewModel) {
        self.viewModel = .init(timetableViewModel: timetableViewModel)
    }

    @Environment(\.sheetDismiss) private var dismiss

    enum Design {
        static let detailFont = Font.system(size: 12)
    }

    var body: some View {
        VStack(spacing: 0) {
            logoView

            Divider()
                .padding(.horizontal, 10)

            switch viewModel.metadataLoadingState {
            case .loading:
                loadingView
            case .loaded:
                ScrollView {
                    VStack(spacing: 15) {
                        headerView
                        timetableListView
                    }
                    .padding(.top, 20)
                }
            }
        }
    }

    private var logoView: some View {
        HStack {
            Logo(orientation: .horizontal)
                .padding(.vertical)
            Spacer()
            AnimatableButton(
                animationOptions: .impact().scale(0.9).backgroundColor(touchDown: .black.opacity(0.1)),
                layoutOptions: [.respectIntrinsicHeight, .respectIntrinsicWidth]
            ) {
                dismiss()
            } configuration: { configuration in
                var configuration = UIButton.Configuration.plain()
                configuration.image = TimetableAsset.xmarkBlack.image
                return configuration
            }
        }
        .padding(.horizontal, 20)
    }

    private var headerView: some View {
        HStack {
            Text(TimetableStrings.timetableMenuMyTimetable)
                .font(Design.detailFont)
                .foregroundColor(Color(uiColor: .secondaryLabel))
            Spacer()
            Button {
            } label: {
                TimetableAsset.navPlus.swiftUIImage
                    .resizable()
                    .frame(width: 25, height: 25)
            }
        }
        .padding(.horizontal, 15)
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }

    private var timetableListView: some View {
        let groupedTimetables = viewModel.groupedTimetables
        return ForEach(groupedTimetables, id: \.id) { group in
            let isEmptyQuarter = group.metadataList.isEmpty
            TimetableMenuSection(
                quarter: group.quarter,
                current: viewModel.currentTimetable,
                isEmptyQuarter: isEmptyQuarter) {
                    timetableSectionContent(for: group.metadataList)
                }
        }
    }

    private func timetableSectionContent(for timetableList: [any TimetableMetadata]) -> some View {
        ForEach(timetableList, id: \.id) { timetable in
            TimetableMenuSectionRow(
                viewModel: viewModel,
                timetableMetadata: timetable,
                isSelected: viewModel.currentTimetable?.id == timetable.id)
        }
    }

}

#Preview {
    let viewModel = TimetableViewModel()
    let _ = Task {
        try await Task.sleep(for: .seconds(1))
        try await viewModel.loadTimetable()
        try await viewModel.loadTimetableList()
    }
    TimetableMenuContentView(timetableViewModel: viewModel)
}
