//
//  TimetableScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import NotificationsInterface
import SharedUIComponents
import SwiftUI
import TimetableInterface
import TimetableUIComponents

public struct TimetableScene: View {
    @Dependency(\.application) private var application
    @Bindable var timetableViewModel: TimetableViewModel
    @State private(set) var searchViewModel: LectureSearchViewModel
    @Binding private(set) var isSearchMode: Bool
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.notificationsUIProvider) private var notificationsUIProvider
    @Environment(\.themeUIProvider) private var themeUIProvider

    public init(
        isSearchMode: Binding<Bool>,
        timetableViewModel: TimetableViewModel,
        lectureSearchRouter: LectureSearchRouter
    ) {
        _isSearchMode = isSearchMode
        self.timetableViewModel = timetableViewModel
        _searchViewModel = State(initialValue: LectureSearchViewModel(
            timetableViewModel: timetableViewModel,
            router: lectureSearchRouter
        ))
    }

    public var body: some View {
        NavigationStack(path: $timetableViewModel.paths) {
            VStack(spacing: 0) {
                toolbarContent
                ZStack {
                    timetable
                    Group {
                        TimetableAsset.searchlistBackground.swiftUIColor
                            .zIndex(1)
                        LectureSearchResultScene(viewModel: searchViewModel)
                            .zIndex(.infinity)
                    }
                    .opacity(isSearchMode ? 1 : 0)
                }
            }
            .ignoresSafeArea(.keyboard)
            .animation(.defaultSpring, value: isSearchMode)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: TimetableDetailSceneTypes.self) {
                detailScene(for: $0)
            }
            .onLoad {
                await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        await errorAlertHandler.withAlert {
                            try await timetableViewModel.loadTimetable()
                        }
                    }
                    group.addTask {
                        await errorAlertHandler.withAlert {
                            try await timetableViewModel.loadTimetableList()
                        }
                    }
                }
            }
            .sheet(isPresented: $timetableViewModel.isThemeSheetPresented) {
                themeUIProvider.menuThemeSelectionSheet()
            }
        }
        .onChange(of: isSearchMode) { _, newValue in
            if newValue, !timetableViewModel.paths.isEmpty {
                timetableViewModel.paths = []
            }
            if !newValue {
                searchViewModel.selectedLecture = nil
            }
        }
        .onChange(of: timetableViewModel.currentTimetable?.quarter) { _, newValue in
            if let newValue {
                searchViewModel.searchingQuarter = newValue
            }
        }
    }

    @ViewBuilder private func detailScene(for type: TimetableDetailSceneTypes) -> some View {
        switch type {
        case .lectureList:
            LectureListScene(viewModel: timetableViewModel)
        case let .lectureDetail(lecture):
            LectureEditDetailScene(
                timetableViewModel: timetableViewModel,
                entryLecture: lecture,
                displayMode: .normal,
                paths: $timetableViewModel.paths
            )
            .handleLectureTimeConflict()
        case let .lectureColorSelection(viewModel):
            let currentTheme = timetableViewModel.currentTimetable?.theme
            let theme = themeViewModel.availableThemes.first(where: { $0.id == currentTheme?.id })
            if let theme {
                LectureColorSelectionListView(
                    theme: theme,
                    viewModel: viewModel
                )
            } else {
                ProgressView()
            }
        case .notificationList:
            AnyView(notificationsUIProvider.makeNotificationsScene())
        }
    }

    private var timetable: some View {
        ZStack {
            TimetableZStack(painter: timetableViewModel.makePainter(
                selectedLecture: searchViewModel.selectedLecture,
                selectedTheme: themeViewModel.selectedTheme,
                availableThemes: themeViewModel.availableThemes
            ))
            .environment(\.lectureTapAction, LectureTapAction(action: { lecture in
                timetableViewModel.paths.append(.lectureDetail(lecture))
            }))
        }
    }
}

struct CircleBadge: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 4, height: 4)
    }
}

struct CircleBadgeModifier: ViewModifier {
    let condition: Bool
    let color: Color

    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content

            if condition {
                CircleBadge(color: .red)
            }
        }
    }
}

extension View {
    func circleBadge(condition: Bool, color: Color = .red) -> some View {
        modifier(CircleBadgeModifier(condition: condition, color: color))
    }
}

#Preview {
    TimetableScene(isSearchMode: .constant(false), timetableViewModel: .init(), lectureSearchRouter: .init())
        .overlaySheet()
}
