//
//  TimetableScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import SwiftUI
import TimetableInterface
import TimetableUIComponents

public struct TimetableScene: View {
    @Dependency(\.application) private var application
    @State private(set) var timetableViewModel = TimetableViewModel()
    @State private(set) var searchViewModel = LectureSearchViewModel()
    @Binding private(set) var isSearchMode: Bool

    public init(isSearchMode: Binding<Bool>) {
        _isSearchMode = isSearchMode
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
            .task {
                await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        await timetableViewModel.loadTimetable()
                    }
                    group.addTask {
                        try await timetableViewModel.loadTimetableList()
                    }
                }
            }
        }
        .onChange(of: isSearchMode) { _, newValue in
            if newValue, !timetableViewModel.paths.isEmpty {
                timetableViewModel.paths = []
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
            LectureEditDetailScene(entryLecture: lecture, displayMode: .normal)
        case .notificationList:
            EmptyView()
        }
    }

    private var timetable: some View {
        ZStack {
            TimetableZStack(painter: timetableViewModel.makePainter(selectedLecture: searchViewModel.selectedLecture))
                .environment(\.lectureTapAction, LectureTapAction(action: { lecture in
                    timetableViewModel.paths.append(.lectureDetail(lecture))
                }))
        }
        .task {
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    await timetableViewModel.loadTimetable()
                }
                group.addTask {
                    try await LectureSearchAPIRepository().fetchSearchPredicates(quarter: TimetableInterface.Quarter(year: 2024, semester: Semester.first))
                }
            }
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
    TimetableScene(isSearchMode: .constant(false))
}
