//
//  EvaluationLectureDetailScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

struct EvaluationLectureDetailScene: View {
    @State private var viewModel: EvaluationLectureDetailViewModel
    @State private var menuAction: EvaluationMenuAction?
    @State private var highlightOpacity = 0.0
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    init(lectureID: EvaluationLectureID, highlightedEvaluationID: EvaluationID? = nil) {
        _viewModel = State(
            initialValue: EvaluationLectureDetailViewModel(
                lectureID: lectureID,
                highlightedEvaluationID: highlightedEvaluationID
            )
        )
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                switch viewModel.contentState {
                case .loading:
                    detailContent(
                        .init(
                            summary: EvaluationPreviewFixtures.summary,
                            myEvaluations: [],
                            evaluations: PagedContent(items: EvaluationPreviewFixtures.feed.map(\.evaluation))
                        )
                    )
                    .redacted(reason: .placeholder)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                case .loaded(let content):
                    detailContent(content)
                }
            }
            .withResponsiveTouch()
            .refreshable {
                await errorAlertHandler.withAlert {
                    try await viewModel.load()
                }
            }
            .onChange(of: viewModel.contentState.value != nil) { _, isLoaded in
                guard isLoaded else { return }
                revealHighlightedEvaluation(using: proxy)
            }
            .onChange(of: viewModel.highlightedEvaluationID) {
                revealHighlightedEvaluation(using: proxy)
            }
        }
        .animation(.defaultSpring, value: viewModel.contentState)
        .background(Color(uiColor: .systemBackground))
        .safeAreaInset(edge: .bottom, spacing: 0) {
            EvaluationWriteFloatingButton {
                viewModel.writeRequest = EvaluationWriteRequest(lectureID: viewModel.lectureID)
            }
            .padding(.bottom, 12)
        }
        .navigationTitle(EvaluationsStrings.detailTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.writeRequest) { request in
            EvaluationWriteScene(lectureID: request.lectureID) { evaluationID in
                errorAlertHandler.withAlert {
                    try await viewModel.didSaveEvaluation(evaluationID)
                }
            }
        }
        .evaluationMenuActions(
            $menuAction,
            onEdit: { evaluationID in
                errorAlertHandler.withAlert {
                    try await viewModel.didSaveEvaluation(evaluationID)
                }
            },
            onReport: { id, reason in
                errorAlertHandler.withAlert {
                    try await viewModel.reportEvaluation(id, reason: reason)
                }
            },
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

    private func detailContent(_ content: EvaluationLectureDetailViewModel.Content) -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            EvaluationLectureDetailHeader(summary: content.summary)

            EvaluationDesignColor.sectionSeparator
                .frame(height: 8)

            if content.allEvaluations.isEmpty {
                ContentUnavailableView {
                    Label(EvaluationsStrings.detailEmptyTitle, systemImage: "text.bubble")
                } description: {
                    Text(EvaluationsStrings.detailEmptyDescription)
                }
                .padding(.vertical, 24)
            }

            ForEach(content.allEvaluations) { evaluation in
                EvaluationRow(
                    evaluation: evaluation,
                    onToggleLike: {
                        errorAlertHandler.withAlert {
                            try await viewModel.toggleLike(evaluation)
                        }
                    },
                    onSelectMenuAction: { menuAction = $0 }
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background {
                    if evaluation.id == viewModel.highlightedEvaluationID {
                        EvaluationDesignColor.accentBackground
                            .opacity(highlightOpacity)
                    }
                }
                .id(evaluation.id)
                .onAppear {
                    Task {
                        await viewModel.loadMoreIfNeeded(after: evaluation)
                    }
                }

                Divider()
                    .padding(.horizontal, 20)
            }
        }
    }

    /// Scrolls to the highlighted evaluation, then fades the highlight out.
    private func revealHighlightedEvaluation(using proxy: ScrollViewProxy) {
        guard let id = viewModel.highlightedEvaluationID, viewModel.contentState.value != nil else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(.smooth) {
                proxy.scrollTo(id, anchor: .center)
                highlightOpacity = 1
            }
            try? await Task.sleep(for: .seconds(1.6))
            withAnimation(.smooth(duration: 0.8)) {
                highlightOpacity = 0
            } completion: {
                viewModel.clearHighlight()
            }
        }
    }
}

/// The primary call to action floating over the evaluation list.
private struct EvaluationWriteFloatingButton: View {
    let action: () -> Void

    var body: some View {
        if #available(iOS 26, *) {
            Button(action: action) {
                label
            }
            .buttonStyle(.glassProminent)
            .tint(EvaluationDesignColor.accent)
        } else {
            Button(action: action) {
                label
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(EvaluationDesignColor.accent)
            .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        }
    }

    private var label: some View {
        Label(EvaluationsStrings.writeButton, systemImage: "pencil")
            .font(.subheadline.weight(.semibold))
    }
}

struct EvaluationLectureDetailHeader: View {
    let summary: LectureEvaluationSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(summary.info.brief.title)
                    .font(.title3.weight(.bold))
                    .accessibilityAddTraits(.isHeader)
                Text(summary.info.brief.instructorDisplayText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !summary.info.metadataText.isEmpty {
                    Text(summary.info.metadataText)
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                }
            }

            Divider()

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 16) {
                    averageRating
                    Spacer(minLength: 0)
                    scoreGrid
                }
                VStack(alignment: .leading, spacing: 16) {
                    averageRating
                    scoreGrid
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }

    private var averageRating: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(summary.averageRating?.ratingText ?? "-")
                    .font(.title2.weight(.bold))
                    .monospacedDigit()
                Text("(\(summary.evaluationCount))")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
            EvaluationStarRating(rating: summary.averageRating ?? 0, starSize: 15)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            [
                summary.averageRating.map { EvaluationsStrings.ratingAccessibility($0.ratingText) }
                    ?? EvaluationsStrings.ratingNone,
                EvaluationsStrings.ratingEvaluationCountAccessibility(summary.evaluationCount),
            ]
            .joined(separator: ", ")
        )
    }

    @ViewBuilder
    private var scoreGrid: some View {
        if let scores = summary.averageScores {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                GridRow {
                    scoreItem(.gradeSatisfaction, scores: scores)
                    scoreItem(.gains, scores: scores)
                }
                GridRow {
                    scoreItem(.teachingSkill, scores: scores)
                    scoreItem(.lifeBalance, scores: scores)
                }
            }
        }
    }

    private func scoreItem(_ criterion: EvaluationCriterion, scores: EvaluationScores) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundStyle(EvaluationDesignColor.star)
            Text(scores[criterion].ratingText)
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
            Text(criterion.displayTitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .lineLimit(1)
        .fixedSize()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        EvaluationLectureDetailScene(lectureID: 1101)
    }
}
