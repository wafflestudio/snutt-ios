//
//  TimetableScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import SwiftUI
import TimetableInterface

public struct TimetableScene: View {
    @Dependency(\.application) private var application
    @StateObject private var timetableViewModel = TimetableViewModel()
    @StateObject private var searchViewModel = LectureSearchViewModel()
    @State private var isSearchMode = false {
        didSet {
            if !isSearchMode {
                application.dismissKeyboard()
            }
            isSearchBarFocused = isSearchMode
        }
    }

    @FocusState private var isSearchBarFocused

    public init() {}

    public var body: some View {
        NavigationStack(path: $timetableViewModel.paths) {
            ZStack {
                timetable
                if isSearchMode {
                    Group {
                        TimetableAsset.searchlistBackground.swiftUIColor
                            .zIndex(1)
                        SearchResultListView(viewModel: searchViewModel)
                            .zIndex(.infinity)
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
            .animation(.defaultSpring, value: isSearchMode)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: TimetableDetailSceneTypes.self) {
                detailScene(for: $0)
            }
            .toolbar {
                toolbarContent
            }
        }
    }

    private func toggleSearchMode() {
        isSearchMode.toggle()
    }

    private func detailScene(for type: TimetableDetailSceneTypes) -> some View {
        switch type {
        case .lectureList:
            LectureListScene(viewModel: timetableViewModel)
        }
    }

    private var timetable: some View {
        ZStack {
            TimetableZStack(viewModel: timetableViewModel)
        }
        .task {
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    await timetableViewModel.loadTimetable()
                }
                group.addTask {
                    try await LectureSearchAPIRepository().fetchTags(quarter: TimetableInterface.Quarter(year: 2024, semester: Semester.first))
                }
            }
        }
    }

    private var searchToolbarView: some View {
        HStack(spacing: 0) {
            ToolbarButton(image: .init(systemName: "chevron.backward")!) {
                toggleSearchMode()
            }
            .padding(.leading, -8)
            SearchInputTextField(query: $searchViewModel.searchQuery)
                .focused($isSearchBarFocused)
                .onSubmit {
                    Task {
                        await searchViewModel.fetchInitialSearchResult()
                    }
                }
            Spacer()
        }
    }

    private var timetableToolbarView: some View {
        HStack(spacing: 0) {
            ToolbarButton(image: TimetableAsset.navMenu.image) {}
                .padding(.leading, -8)
            Text(timetableViewModel.timetableTitle)
                .font(.system(size: 17, weight: .bold))
                .minimumScaleFactor(0.9)
                .lineLimit(1)
                .padding(.trailing, 8)
            Text(TimetableStrings.timetableToolbarTotalCredit(timetableViewModel.totalCredit))
                .font(.system(size: 12))
                .foregroundColor(Color(UIColor.secondaryLabel))
            Spacer()
            ToolbarButton(image: TimetableAsset.navAlarmOff.image) {}
        }
    }

    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .principal) {
                GeometryReader { proxy in
                    HStack(spacing: 0) {
                        if isSearchMode {
                            searchToolbarView
                                .transition(toolbarTransition(from: .bottom))
                        } else {
                            timetableToolbarView
                                .transition(toolbarTransition(from: .top))
                        }
                        ToolbarButton(image: .init(systemName: "magnifyingglass")!) {
                            toggleSearchMode()
                        }
                    }
                    .animation(.defaultSpring, value: isSearchMode)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
                .clipped()
            }
        }
    }

    private func toolbarTransition(from edge: Edge) -> AnyTransition {
        if #available(iOS 17, *) {
            if edge == .top {
                AnyTransition.asymmetric(
                    insertion: AnyTransition(.blurReplace(.downUp).combined(with: .push(from: .top))),
                    removal: AnyTransition(.blurReplace(.downUp).combined(with: .push(from: .bottom)))
                )
            } else {
                AnyTransition.asymmetric(
                    insertion: AnyTransition(.blurReplace(.downUp).combined(with: .push(from: .bottom))),
                    removal: AnyTransition(.blurReplace(.downUp).combined(with: .push(from: .top)))
                )
            }
        } else {
            AnyTransition.move(edge: edge).combined(with: .opacity)
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
    TimetableScene()
}
