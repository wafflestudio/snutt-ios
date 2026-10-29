//
//  EvaluationHomeScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

#if DEBUG
public struct EvaluationScene: View {
    public init() {}

    public var body: some View {
        EvaluationHomeScene()
    }
}
#endif

public struct EvaluationHomeScene: View {
    @State private var viewModel: EvaluationHomeViewModel
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    public init() {
        _viewModel = State(initialValue: EvaluationHomeViewModel())
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            content
                .navigationTitle("강의평")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: EvaluationDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
        .onLoad {
            await errorAlertHandler.withAlert {
                try await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.homeState {
        case .loading:
            scrollContent(homeContent: nil)
        case .loaded(let state):
            scrollContent(homeContent: state)
        }
    }

    private func scrollContent(homeContent: EvaluationHomeContent?) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                EvaluationSearchEntryView(
                    onSearch: viewModel.openSearch,
                    onFilter: viewModel.openSearch
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 18)

                mainFeedSection(homeContent: homeContent)

                takenLectureSection(homeContent: homeContent)
            }
            .animation(.defaultSpring, value: homeContent?.selectedSort)
        }
        .withResponsiveTouch()
        .background(Color(uiColor: .systemBackground))
        .refreshable {
            await errorAlertHandler.withAlert {
                if homeContent == nil {
                    try await viewModel.load()
                } else {
                    try await viewModel.refresh()
                }
            }
        }
    }

    private func mainFeedSection(homeContent: EvaluationHomeContent?) -> some View {
        EvaluationMainFeedSection(
            mode: mainFeedMode(homeContent: homeContent),
            onSelectSort: { sort in
                errorAlertHandler.withAlert {
                    try await viewModel.selectSort(sort)
                }
            },
            onSelectEvaluation: viewModel.openEvaluationDetail,
            onOpenSeeAll: {
                let sort = homeContent?.selectedSort.kind ?? .recommended
                viewModel.openAllEvaluations(sort: sort)
            }
        )
    }

    @ViewBuilder
    private func takenLectureSection(homeContent: EvaluationHomeContent?) -> some View {
        switch takenLectureMode(homeContent: homeContent) {
        case nil:
            EmptyView()

        case let mode?:
            EvaluationTakenLectureSection(
                mode: mode,
                onOpenMyEvaluations: viewModel.openMyEvaluations,
                onSelectLecture: viewModel.openLectureDetail,
                onWriteEvaluation: viewModel.openWriteEvaluation
            )
            .padding(.top, 18)
        }
    }

    private func mainFeedMode(homeContent: EvaluationHomeContent?) -> EvaluationMainFeedSection.Mode {
        guard let homeContent else {
            return .loading
        }
        return .loaded(
            feed: homeContent.mainFeed,
            selectedSort: homeContent.selectedSort,
            availableSorts: homeContent.availableSorts
        )
    }

    private func takenLectureMode(homeContent: EvaluationHomeContent?) -> EvaluationTakenLectureSection.Mode? {
        guard let homeContent else {
            return .loading
        }
        guard let feed = homeContent.takenLectureFeed else {
            return nil
        }
        return .loaded(feed)
    }

    private func destinationView(for destination: EvaluationDestination) -> some View {
        Group {
            switch destination {
            case .search:
                EvaluationSearchScene(
                    onBack: {
                        if !viewModel.path.isEmpty {
                            viewModel.path.removeLast()
                        }
                    },
                    onSelectEvaluation: viewModel.openEvaluationDetail
                )
                .toolbar(.hidden, for: .navigationBar)
                .toolbar(.hidden, for: .tabBar)

            case .filter:
                placeholder("필터 화면")
                    .navigationTitle("필터")

            case .evaluationDetail:
                placeholder("강의평 상세 화면")
                    .navigationTitle("강의평")

            case .lectureDetail(let lectureID):
                EvaluationLectureDetailScene(detail: lectureDetailContent(for: lectureID))

            case .writeEvaluation:
                placeholder("강의평 작성")
                    .navigationTitle("강의평 작성")

            case .myEvaluations:
                placeholder("나의 강의평")
                    .navigationTitle("나의 강의평")

            case .allEvaluations(let sort):
                EvaluationSeeAllScene(
                    initialSortKind: sort,
                    availableSorts: availableSortsForDestination(initialSortKind: sort),
                    onSearch: viewModel.openSearch,
                    onSelectEvaluation: viewModel.openEvaluationDetail
                )
                .navigationTitle("강의평 전체보기")
            }
        }
    }

    private func availableSortsForDestination(initialSortKind: EvaluationSort.Kind) -> [EvaluationSort] {
        guard case .loaded(let home) = viewModel.homeState else {
            return [EvaluationSort(id: -1, kind: initialSortKind)]
        }
        return home.availableSorts
    }

    private func lectureDetailContent(for lectureID: EvaluationLectureID) -> EvaluationLectureDetailContent {
        guard case .loaded(let homeContent) = viewModel.homeState,
            let lecture = homeContent.takenLectureFeed?.lectures.first(where: { $0.id == lectureID })
        else {
            return .empty(lectureID: lectureID)
        }
        return EvaluationLectureDetailContent(takenLecture: lecture)
    }

    private func placeholder(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
    }

}

struct EvaluationSearchScene: View {
    let onBack: () -> Void
    let onSelectEvaluation: (EvaluationID) -> Void

    @State private var query = "인공지능"
    @State private var selectedFilters = EvaluationSearchFilter.previewSelected
    @State private var isFilterSheetPresented = false

    private var results: [LectureEvaluation] {
        EvaluationSearchResultFixtures.results
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                EvaluationSearchInputBar(
                    query: $query,
                    onBack: onBack,
                    onFilter: {
                        isFilterSheetPresented = true
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)

                if !selectedFilters.isEmpty {
                    EvaluationSearchFilterChips(
                        filters: selectedFilters,
                        onRemove: removeFilter
                    )
                    .padding(.top, 9)
                }

                Divider()
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                ForEach(results) { evaluation in
                    EvaluationSearchResultRow(
                        evaluation: evaluation,
                        onTap: {
                            onSelectEvaluation(evaluation.id)
                        }
                    )

                    Divider()
                        .padding(.horizontal, 20)
                }
            }
        }
        .withResponsiveTouch()
        .background(Color(uiColor: .systemBackground))
        .sheet(isPresented: $isFilterSheetPresented) {
            EvaluationSearchFilterSheet(selectedFilters: $selectedFilters)
        }
    }

    private func removeFilter(_ filter: EvaluationSearchFilter) {
        withAnimation(.defaultSpring) {
            selectedFilters.removeAll { $0 == filter }
        }
    }
}

struct EvaluationSearchResultRow: View {
    let evaluation: LectureEvaluation
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(evaluation.lecture.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .label))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(evaluation.rating > 0 ? Color.yellow : Color(uiColor: .systemGray4))

                    if evaluation.rating > 0 {
                        Text(String(format: "%.1f", evaluation.rating))
                            .foregroundStyle(Color(uiColor: .label))
                    }

                    Text(evaluation.rating > 0 ? "(\(evaluation.likeCount))" : "(-)")
                        .foregroundStyle(Color(uiColor: .secondaryLabel))

                    Text("·")
                        .foregroundStyle(Color(uiColor: .secondaryLabel))

                    Text(evaluation.lecture.instructor ?? "교수명")
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .frame(height: 86)
            .contentShape(Rectangle())
        }
        .buttonStyle(.animatable(scale: 0.98))
        .accessibilityLabel("\(evaluation.lecture.title), \(evaluation.lecture.instructor ?? "교수명")")
    }
}

private enum EvaluationSearchResultFixtures {
    static let results: [LectureEvaluation] = [
        result(id: 901, title: "인공지능 신뢰성", instructor: "박상철", rating: 3.0, reviewCount: 3),
        result(id: 902, title: "인공지능과 생활", instructor: "교수님", rating: 0.0, reviewCount: 0),
        result(id: 903, title: "인공지능", instructor: "교수명", rating: 4.6, reviewCount: 3),
        result(id: 904, title: "인공지능", instructor: "교수명", rating: 4.6, reviewCount: 3),
    ]

    private static func result(
        id: EvaluationID,
        title: String,
        instructor: String,
        rating: Double,
        reviewCount: Int
    ) -> LectureEvaluation {
        LectureEvaluation(
            id: id,
            lecture: EvaluationLectureBrief(
                id: EvaluationLectureID(id.rawValue),
                title: title,
                instructor: instructor
            ),
            rating: rating,
            content: "",
            year: 2025,
            semester: 2,
            likeCount: reviewCount,
            isLiked: false,
            isReportable: true
        )
    }
}

#if DEBUG
#Preview("Loading") {
    NavigationStack {
        EvaluationHomeScene.PreviewContent(homeContent: nil)
            .navigationTitle("강의평")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Loaded") {
    NavigationStack {
        EvaluationHomeScene.PreviewContent(homeContent: EvaluationPreviewFixtures.homeContent)
            .navigationTitle("강의평")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Search") {
    EvaluationSearchScene(
        onBack: {},
        onSelectEvaluation: { _ in }
    )
}

extension EvaluationHomeScene {
    struct PreviewContent: View {
        let homeContent: EvaluationHomeContent?

        var body: some View {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    EvaluationSearchEntryView(onSearch: {}, onFilter: {})
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 18)

                    EvaluationMainFeedSection(
                        mode: mainFeedMode,
                        onSelectSort: { _ in },
                        onSelectEvaluation: { _ in },
                        onOpenSeeAll: {}
                    )

                    if let takenLectureMode {
                        EvaluationTakenLectureSection(
                            mode: takenLectureMode,
                            onOpenMyEvaluations: {},
                            onSelectLecture: { _ in },
                            onWriteEvaluation: { _ in }
                        )
                        .padding(.top, 18)
                    }
                }
            }
            .withResponsiveTouch()
            .background(Color(uiColor: .systemBackground))
        }

        private var mainFeedMode: EvaluationMainFeedSection.Mode {
            guard let homeContent else {
                return .loading
            }
            return .loaded(
                feed: homeContent.mainFeed,
                selectedSort: homeContent.selectedSort,
                availableSorts: homeContent.availableSorts
            )
        }

        private var takenLectureMode: EvaluationTakenLectureSection.Mode? {
            guard let homeContent else {
                return .loading
            }
            guard let feed = homeContent.takenLectureFeed else {
                return nil
            }
            return .loaded(feed)
        }
    }
}
#endif
