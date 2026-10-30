//
//  MyEvaluationsScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

struct MyEvaluationsScene: View {
    @State private var viewModel = MyEvaluationsViewModel()
    @State private var menuAction: EvaluationMenuAction?
    @State private var scrolledTarget: ScrollTarget?
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    private enum ScrollTarget: Hashable {
        case header(MyEvaluationsViewModel.Section.ID)
        case row(EvaluationID)
    }

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
            .onLoad {
                await errorAlertHandler.withAlert {
                    try await viewModel.load()
                }
            }
    }

    private var content: some View {
        let sections = viewModel.sections
        // The empty state stays inside the scroll view so pull to refresh still works.
        return ScrollView {
            if let sections, sections.isEmpty {
                ContentUnavailableView {
                    Label(EvaluationsStrings.myEvaluationsEmptyTitle, systemImage: "square.and.pencil")
                } description: {
                    Text(EvaluationsStrings.myEvaluationsEmptyDescription)
                }
                .containerRelativeFrame(.vertical)
            } else {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if let sections {
                        sectionList(sections)
                    } else {
                        sectionList(Self.placeholderSections)
                            .redacted(reason: .placeholder)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
                .scrollTargetLayout()
            }
        }
        .withResponsiveTouch()
        .scrollPosition(id: $scrolledTarget, anchor: .top)
        // The current section's header sits in a top bar instead of a pinned header,
        // so it gets the same scroll edge effect as the navigation bar.
        .topBar {
            if let current = currentSection(in: sections ?? Self.placeholderSections) {
                sectionHeader(current)
                    .redacted(reason: sections == nil ? .placeholder : [])
                    .animation(nil, value: current.id)
            }
        }
        .refreshable {
            await errorAlertHandler.withAlert {
                try await viewModel.load()
            }
        }
    }

    /// The section whose rows sit at the top of the scroll view. While a section's own header is the topmost view,
    /// the previous section stays current so the bar never repeats the header right below it.
    private func currentSection(in sections: [MyEvaluationsViewModel.Section]) -> MyEvaluationsViewModel.Section? {
        switch scrolledTarget {
        case .row(let id):
            sections.first { section in section.items.contains { $0.id == id } } ?? sections.first
        case .header(let sectionID):
            sections.firstIndex { $0.id == sectionID }.map { sections[max($0 - 1, 0)] } ?? sections.first
        case nil:
            sections.first
        }
    }

    private func sectionList(_ sections: [MyEvaluationsViewModel.Section]) -> some View {
        ForEach(sections) { section in
            // The first section's header is shown by the top bar alone.
            if section.id != sections.first?.id {
                sectionHeader(section)
                    .overlay(alignment: .bottom) {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                    .id(ScrollTarget.header(section.id))
            }
            Section {
                ForEach(section.items) { item in
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
                    // An overlay keeps one view per element, which lazy stacks need for stable identity.
                    .overlay(alignment: .bottom) {
                        if item.id != section.items.last?.id {
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                    .onAppear {
                        Task {
                            await viewModel.loadMoreIfNeeded(after: item)
                        }
                    }
                    .id(ScrollTarget.row(item.id))
                }
            }
        }
    }

    private func sectionHeader(_ section: MyEvaluationsViewModel.Section) -> some View {
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

    private static var placeholderSections: [MyEvaluationsViewModel.Section] {
        [
            MyEvaluationsViewModel.Section(
                quarter: EvaluationPreviewFixtures.feed[0].evaluation.quarter,
                items: EvaluationPreviewFixtures.feed
            )
        ]
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
