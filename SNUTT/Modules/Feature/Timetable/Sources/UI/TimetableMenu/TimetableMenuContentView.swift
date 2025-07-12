//
//  TimetableMenuContentView.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import TimetableInterface

struct TimetableMenuContentView: View {
    @State private var viewModel: TimetableMenuViewModel
    init(timetableViewModel: TimetableViewModel) {
        _viewModel = .init(initialValue: .init(timetableViewModel: timetableViewModel))
    }

    @Environment(\.sheetDismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    @State private var createTimetableSheetType: CreateTimetableSheet.PresentationType?
    private var isCreateTimetableSheetPresented: Binding<Bool> {
        .init(
            get: { createTimetableSheetType != nil },
            set: { newValue in
                if !newValue {
                    createTimetableSheetType = nil
                }
            }
        )
    }

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
            case let .loaded(metadataList):
                ScrollView {
                    VStack(spacing: 15) {
                        headerView
                        timetableListView
                    }
                    .animation(.defaultSpring, value: metadataList.map(\.id))
                    .padding(.top, 20)
                }
            }
        }
        .sheet(
            isPresented: isCreateTimetableSheetPresented,
            onDismiss: {
                createTimetableSheetType = nil
            }
        ) {
            CreateTimetableSheet(viewModel: viewModel, presentationType: createTimetableSheetType ?? .picker)
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
            } configuration: { _ in
                var configuration = UIButton.Configuration.plain()
                configuration.image = TimetableAsset.xmark.image
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
                createTimetableSheetType = .picker
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
                isEmptyQuarter: isEmptyQuarter
            ) {
                timetableSectionContent(quarter: group.quarter, for: group.metadataList)
            }
        }
    }

    private func timetableSectionContent(quarter: Quarter, for timetableList: [TimetableMetadata]) -> some View {
        Group {
            if timetableList.isEmpty {
                Button {
                    createTimetableSheetType = .fixed(quarter)
                } label: {
                    HStack {
                        Text("+ 시간표 추가하기")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                }
                .buttonStyle(.plain)
            } else {
                ForEach(timetableList, id: \.id) { timetable in
                    TimetableMenuSectionRow(
                        viewModel: viewModel,
                        timetableMetadata: timetable,
                        isSelected: viewModel.currentTimetable?.id == timetable.id
                    )
                }
            }
        }
    }
}

#Preview {
    let viewModel = TimetableViewModel()
    let _ = Task {
        try await Task.sleep(for: .milliseconds(200))
        try await viewModel.loadTimetable()
        try await viewModel.loadTimetableList()
    }
    TimetableMenuContentView(timetableViewModel: viewModel)
}
