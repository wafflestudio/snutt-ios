//
//  MyEvaluationsScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Observation
import SharedUIComponents
import SwiftUI
import SwiftUIUtility

struct MyEvaluationsScene: View {
    private typealias Section = MyEvaluationsViewModel.Section

    @State private var viewModel = MyEvaluationsViewModel()
    @State private var menuAction: EvaluationMenuAction?
    @State private var scrollPosition = MyEvaluationsScrollPosition()
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        content
            .animation(.defaultSpring, value: viewModel.evaluationsState)
            .background(Color(uiColor: .systemBackground))
            .navigationTitle(EvaluationsStrings.myEvaluationsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .evaluationMenuActions(
                $menuAction,
                onEdit: { _ in
                    errorAlertHandler.withAlert {
                        try await viewModel.load()
                    }
                },
                onReport: { _, _ in },
                onDelete: { id in
                    errorAlertHandler.withAlert {
                        try await viewModel.deleteEvaluation(id)
                    }
                }
            )
            // Runs on every appearance until the evaluations arrive, so a load cut short by leaving the screen resumes.
            .task {
                guard viewModel.evaluationsState.value == nil else { return }
                await errorAlertHandler.withAlert {
                    try await viewModel.load()
                }
            }
    }

    private var content: some View {
        let sections = displayedSections
        // Every state stays inside the scroll view so pull to refresh still works.
        return ScrollView {
            switch viewModel.evaluationsState {
            case .loading:
                entryList(sections)
                    .redacted(reason: .placeholder)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            case .loaded where sections.isEmpty:
                ContentUnavailableView {
                    Label(EvaluationsStrings.myEvaluationsEmptyTitle, systemImage: "square.and.pencil")
                } description: {
                    Text(EvaluationsStrings.myEvaluationsEmptyDescription)
                }
                .containerRelativeFrame(.vertical)
            case .loaded:
                entryList(sections)
            case .failed:
                EvaluationLoadFailedView(retry: retryLoad)
                    .containerRelativeFrame(.vertical)
            }
        }
        .withResponsiveTouch()
        // Binds through the observable so only the top bar, which reads the position, updates while scrolling.
        .scrollPosition(id: Bindable(scrollPosition).target, anchor: .top)
        // The current section's header sits in a top bar instead of a pinned header,
        // so it gets the same scroll edge effect as the navigation bar.
        .topBar {
            MyEvaluationsCurrentSectionBar(
                sections: sections,
                scrollPosition: scrollPosition,
                isPlaceholder: viewModel.evaluationsState.value == nil
            )
        }
        .refreshable {
            await errorAlertHandler.withAlert {
                try await viewModel.load()
            }
        }
    }

    /// The loaded sections, the skeleton's while loading, and none after a failure.
    private var displayedSections: [Section] {
        switch viewModel.evaluationsState {
        case .loading: Self.placeholderSections
        case .loaded: viewModel.sections ?? []
        case .failed: []
        }
    }

    private func entryList(_ sections: [Section]) -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(MyEvaluationsEntry.entries(in: sections)) { entry in
                // One container per entry keeps the lazy stack at a single view per element.
                VStack(spacing: 0) {
                    switch entry {
                    case .header(let section):
                        MyEvaluationsSectionHeader(section: section)
                            .overlay(alignment: .bottom) {
                                Divider()
                                    .padding(.horizontal, 20)
                            }
                    case .row(let item, let showsDivider):
                        row(item, showsDivider: showsDivider)
                    }
                }
            }
        }
        .scrollTargetLayout()
    }

    private func row(_ item: EvaluationWithLecture, showsDivider: Bool) -> some View {
        MyEvaluationRow(
            item: item,
            onToggleLike: {
                errorAlertHandler.withAlert {
                    try await viewModel.toggleLike(item.evaluation)
                }
            },
            onSelectMenuAction: { menuAction = $0 }
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Divider()
                    .padding(.horizontal, 20)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadMoreIfNeeded(after: item)
            }
        }
    }

    private func retryLoad() {
        errorAlertHandler.withAlert {
            try await viewModel.load()
        }
    }

    private static var placeholderSections: [Section] {
        [
            Section(
                quarter: EvaluationPreviewFixtures.feed[0].evaluation.quarter,
                items: EvaluationPreviewFixtures.feed
            )
        ]
    }
}

/// The scroll view's topmost entry, kept in an observable so reading it invalidates only the views that do.
@MainActor
@Observable
private final class MyEvaluationsScrollPosition {
    var target: MyEvaluationsEntry.ID?
}

/// The list flattened into section headers and rows, so each is a direct child of the scroll target layout.
private enum MyEvaluationsEntry: Identifiable {
    enum ID: Hashable {
        case header(MyEvaluationsViewModel.Section.ID)
        case row(EvaluationID)
    }

    case header(MyEvaluationsViewModel.Section)
    case row(EvaluationWithLecture, showsDivider: Bool)

    var id: ID {
        switch self {
        case .header(let section): .header(section.id)
        case .row(let item, _): .row(item.id)
        }
    }

    /// The first section's header is left out, since the top bar shows it.
    static func entries(in sections: [MyEvaluationsViewModel.Section]) -> [MyEvaluationsEntry] {
        sections.enumerated().flatMap { index, section in
            let header: [MyEvaluationsEntry] = index == 0 ? [] : [.header(section)]
            let rows = section.items.map { item in
                MyEvaluationsEntry.row(item, showsDivider: item.id != section.items.last?.id)
            }
            return header + rows
        }
    }
}

/// The header of the section whose rows sit at the top of the scroll view.
private struct MyEvaluationsCurrentSectionBar: View {
    let sections: [MyEvaluationsViewModel.Section]
    let scrollPosition: MyEvaluationsScrollPosition
    let isPlaceholder: Bool

    var body: some View {
        if let current = currentSection {
            MyEvaluationsSectionHeader(section: current)
                .redacted(reason: isPlaceholder ? .placeholder : [])
                .animation(nil, value: current.id)
        }
    }

    /// While a section's own header is the topmost view, the previous section stays current
    /// so the bar never repeats the header right below it.
    private var currentSection: MyEvaluationsViewModel.Section? {
        switch scrollPosition.target {
        case .row(let id):
            sections.first { section in section.items.contains { $0.id == id } } ?? sections.first
        case .header(let sectionID):
            sections.firstIndex { $0.id == sectionID }.map { sections[max($0 - 1, 0)] } ?? sections.first
        case nil:
            sections.first
        }
    }
}

private struct MyEvaluationsSectionHeader: View {
    let section: MyEvaluationsViewModel.Section

    var body: some View {
        HStack(spacing: 6) {
            Text(section.quarter.evaluationDisplayText)
                .font(.subheadline.weight(.semibold))
            Text(EvaluationsStrings.myEvaluationsCount(section.items.count))
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(Color(uiColor: .tertiarySystemFill), in: .capsule)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

private struct MyEvaluationRow: View {
    let item: EvaluationWithLecture
    let onToggleLike: () -> Void
    let onSelectMenuAction: (EvaluationMenuAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink(value: EvaluationDestination.lectureDetail(item.lecture.id, referrer: .myReviews)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.lecture.title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Text(item.lecture.instructorDisplayText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.animatable(scale: 0.98))
            .accessibilityElement(children: .combine)

            EvaluationRow(
                evaluation: item.evaluation,
                contentLineLimit: 3,
                showsQuarter: false,
                onToggleLike: onToggleLike,
                onSelectMenuAction: onSelectMenuAction
            )
        }
    }
}

#Preview {
    NavigationStack {
        MyEvaluationsScene()
    }
}
