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
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        content
            .animation(.defaultSpring, value: viewModel.evaluationsState)
            .background(Color(uiColor: .systemBackground))
            .navigationTitle(EvaluationsStrings.myEvaluationsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .evaluationMenuActionAlerts(
                $menuAction,
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

    @ViewBuilder
    private var content: some View {
        if let sections = viewModel.sections, sections.isEmpty {
            ContentUnavailableView {
                Label(EvaluationsStrings.myEvaluationsEmptyTitle, systemImage: "square.and.pencil")
            } description: {
                Text(EvaluationsStrings.myEvaluationsEmptyDescription)
            }
            .refreshable {
                await errorAlertHandler.withAlert {
                    try await viewModel.load()
                }
            }
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    if let sections = viewModel.sections {
                        sectionList(sections)
                    } else {
                        sectionList(Self.placeholderSections)
                            .redacted(reason: .placeholder)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
            }
            .withResponsiveTouch()
            .refreshable {
                await errorAlertHandler.withAlert {
                    try await viewModel.load()
                }
            }
        }
    }

    private func sectionList(_ sections: [MyEvaluationsViewModel.Section]) -> some View {
        ForEach(sections) { section in
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
                    .onAppear {
                        Task {
                            await viewModel.loadMoreIfNeeded(after: item)
                        }
                    }

                    if item.id != section.items.last?.id {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            } header: {
                HStack {
                    Text(section.quarter.evaluationDisplayText)
                    Spacer()
                    Text(EvaluationsStrings.myEvaluationsCount(section.items.count))
                        .monospacedDigit()
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .frame(minHeight: 44)
                .background(EvaluationDesignColor.sectionSeparator)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)
            }
        }
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
            NavigationLink(value: EvaluationDestination.lectureDetail(item.lecture.id)) {
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
