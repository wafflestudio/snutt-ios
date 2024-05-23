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
    @State private var timetableViewModel = TimetableViewModel()
    @State private var searchViewModel = LectureSearchViewModel()
    @State private var isMenuPresented = false
    @Binding private var isSearchMode: Bool {
        didSet {
            if !isSearchMode {
                application.dismissKeyboard()
            }
            isSearchBarFocused = isSearchMode
        }
    }
    @FocusState private var isSearchBarFocused

    public init(isSearchMode: Binding<Bool>) {
        _isSearchMode = isSearchMode
    }

    public var body: some View {
        NavigationStack(path: $timetableViewModel.paths) {
            ZStack {
                timetable
                if isSearchMode {
                    Group {
                        TimetableAsset.searchlistBackground.swiftUIColor
                            .zIndex(1)
                        LectureSearchResultScene(viewModel: searchViewModel)
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
            TimetableZStack(painter: timetableViewModel)
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
            ToolbarButton(image: TimetableAsset.chevronLeft.image) {
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
        .onAppear {
            isSearchBarFocused = true
        }
    }

    private var timetableToolbarView: some View {
        HStack(spacing: 0) {
            ToolbarButton(image: TimetableAsset.navMenu.image) {
                timetableViewModel.isMenuPresented.toggle()
            }
            .padding(.leading, -8)
            .timetableMenuSheet(isPresented: $timetableViewModel.isMenuPresented, viewModel: timetableViewModel)

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
                    }
                    .animation(.defaultSpring, value: isSearchMode)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
                .clipped()
            }
        }
    }

    private func toolbarTransition(from edge: Edge) -> AnyTransition {
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
