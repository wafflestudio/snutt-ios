//
//  FriendsScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import FriendsInterface
import SharedUIComponents
import SwiftUI
import ThemesInterface
import TimetableInterface

public struct FriendsScene: View {
    struct SelectedLecture: Identifiable {
        let id: String
        let lecture: Lecture
        let quarter: Quarter

        init(lecture: Lecture, quarter: Quarter) {
            self.id = lecture.id
            self.lecture = lecture
            self.quarter = quarter
        }
    }

    @AppStorage("isNewToFriendsService") private var isNewToFriendsService: Bool = true
    @State var viewModel: FriendsViewModel = .init()
    @State private var selectedLecture: SelectedLecture?
    @Environment(\.timetableUIProvider) private var timetableUIProvider
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    private var shouldShowGuidePopup: Bool {
        isNewToFriendsService || viewModel.isGuidePopupPresented
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch viewModel.selectedFriendContent {
                case .loading:
                    headerView(friendContent: nil)
                    timetableView(friendContent: nil)
                case .loaded(let friendContent):
                    VStack(spacing: 0) {
                        headerView(friendContent: friendContent)
                        timetableView(friendContent: friendContent)
                    }
                    .animation(.none, value: friendContent.friend.id)
                case .empty:
                    EmptyFriendView {
                        viewModel.isGuidePopupPresented = true
                    }
                case .failed:
                    headerView(friendContent: nil)
                    timetableView(friendContent: nil).opacity(0.5)
                }
            }
            .animation(.defaultSpring, value: viewModel.selectedFriend?.id)
            .customPopup(
                isPresented: Binding(
                    get: { shouldShowGuidePopup },
                    set: { newValue in
                        if !newValue {
                            isNewToFriendsService = false
                            viewModel.isGuidePopupPresented = false
                        }
                    }
                )
            ) {
                FriendsGuidePopup()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onLoad {
                errorAlertHandler.withAlert {
                    try await viewModel.initialLoadFriends()
                }
            }
            .sheet(isPresented: $viewModel.isRequestSheetPresented) {
                FriendRequestOptionSheet(friendsViewModel: viewModel)
            }
            .sheet(item: $selectedLecture) { selected in
                timetableUIProvider.makeLectureDetailPreview(
                    lecture: selected.lecture,
                    quarter: selected.quarter,
                    options: [.showDismissButton]
                )
            }
        }
    }

    private var placeholderText: String {
        String(repeating: " ", count: 15)
    }

    private func headerView(friendContent: FriendContent?) -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                Text(friendContent?.friend.effectiveDisplayName ?? placeholderText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(uiColor: .label))
            }
            Spacer()
            if let friendContent, !friendContent.quarters.isEmpty {
                quarterPicker(for: friendContent)
            } else {
                Text(placeholderText)
                    .padding(.trailing, 10)
            }
        }
        .redacted(reason: friendContent == nil ? .placeholder : [])
        .frame(height: 48)
        .padding(.horizontal, 16)
    }

    private func quarterPicker(for friend: FriendContent) -> some View {
        Picker(
            "Quarter",
            selection: Binding(
                get: { friend.selectedQuarter },
                set: { newValue in
                    errorAlertHandler.withAlert {
                        try await viewModel.selectQuarter(newValue)
                    }
                }
            )
        ) {
            ForEach(friend.quarters, id: \.self) { quarter in
                Text(quarter.localizedDescription).tag(quarter)
            }
        }
        .pickerStyle(.menu)
        .font(.system(size: 14))
    }

    private func timetableView(friendContent: FriendContent?) -> some View {
        timetableUIProvider.timetableView(
            timetable: friendContent?.timetableLoadState.timetable,
            configuration: viewModel.timetableConfiguration,
            preferredTheme: themeViewModel.selectedTheme,
            availableThemes: themeViewModel.availableThemes
        )
        .environment(
            \.lectureTapAction,
            LectureTapAction(action: { lecture in
                guard let quarter = friendContent?.selectedQuarter else { return }
                selectedLecture = SelectedLecture(lecture: lecture, quarter: quarter)
            })
        )
        .id(friendContent?.friend.id)
        .ignoresSafeArea(.keyboard)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                viewModel.isMenuPresented.toggle()
            } label: {
                Image(systemName: "line.3.horizontal")
            }
            .friendMenuSheet(isPresented: $viewModel.isMenuPresented, viewModel: viewModel)
        }

        ToolbarItem(placement: .principal) {
            HStack(spacing: 4) {
                Text(FriendsStrings.friendTimetableTitle)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)

                Button {
                    viewModel.isGuidePopupPresented = true
                } label: {
                    FriendsAsset.friendInfo.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 17)
                }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewModel.isRequestSheetPresented = true
            } label: {
                Image(systemName: "person.badge.plus")
            }
        }
    }
}

extension Quarter {
    var localizedDescription: String {
        FriendsStrings.timetableQuarter(year, semester.localizedDescription)
    }
}

extension Semester {
    var localizedDescription: String {
        switch self {
        case .first:
            FriendsStrings.timetableSemester1
        case .summer:
            FriendsStrings.timetableSemesterSummer
        case .second:
            FriendsStrings.timetableSemester2
        case .winter:
            FriendsStrings.timetableSemesterWinter
        }
    }
}

#Preview {
    FriendsScene()
        .overlaySheet()
        .overlayPopup()
}
