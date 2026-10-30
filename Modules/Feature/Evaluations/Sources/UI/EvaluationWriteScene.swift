//
//  EvaluationWriteScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

/// The evaluation form, presented modally so it can be confirmed or discarded as a unit.
struct EvaluationWriteScene: View {
    @State private var viewModel: EvaluationWriteViewModel
    @State private var isDiscardConfirmationPresented = false
    @FocusState private var isContentFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    private let onComplete: (EvaluationID) -> Void

    init(lectureID: EvaluationLectureID, onComplete: @escaping (EvaluationID) -> Void) {
        _viewModel = State(initialValue: EvaluationWriteViewModel(lectureID: lectureID))
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.targetState {
                case .loading:
                    form(target: EvaluationPreviewFixtures.writeTarget)
                        .redacted(reason: .placeholder)
                        .allowsHitTesting(false)
                case .loaded(let target):
                    form(target: target)
                }
            }
            .animation(.defaultSpring, value: viewModel.targetState)
            .navigationTitle(EvaluationsStrings.writeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(EvaluationsStrings.cancel, systemImage: "xmark") {
                        if viewModel.hasUnsavedChanges {
                            isDiscardConfirmationPresented = true
                        } else {
                            dismiss()
                        }
                    }
                    .confirmationDialog(
                        EvaluationsStrings.writeDiscardTitle,
                        isPresented: $isDiscardConfirmationPresented,
                        titleVisibility: .visible
                    ) {
                        Button(EvaluationsStrings.writeDiscardConfirm, role: .destructive) {
                            dismiss()
                        }
                        Button(EvaluationsStrings.writeDiscardKeepEditing, role: .cancel) {}
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    submitButton
                }
            }
        }
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
        .onLoad {
            await errorAlertHandler.withAlert {
                try await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private var submitButton: some View {
        switch viewModel.submissionState {
        case .editing:
            Button(EvaluationsStrings.writeSubmit, systemImage: "checkmark") {
                isContentFocused = false
                errorAlertHandler.withAlert {
                    guard let evaluationID = try await viewModel.submit() else { return }
                    dismiss()
                    onComplete(evaluationID)
                }
            }
            .tint(EvaluationDesignColor.accent)
            .disabled(!viewModel.canSubmit)
        case .submitting:
            ProgressView()
        }
    }

    private func form(target: EvaluationWriteTarget) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(target.lecture.title)
                        .font(.title3.weight(.bold))
                    Text(target.lecture.instructorDisplayText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)
                .accessibilityElement(children: .combine)

                VStack(alignment: .leading, spacing: 28) {
                    formSection(EvaluationsStrings.writeSemester) {
                        semesterPicker(target: target)
                    }

                    formSection(EvaluationsStrings.writeOverallSection) {
                        VStack(alignment: .leading, spacing: 20) {
                            ratingRow(
                                title: EvaluationsStrings.writeOverall,
                                rating: $viewModel.draft.rating,
                                starSize: 32
                            )
                            ForEach(EvaluationCriterion.allCases, id: \.self) { criterion in
                                ratingRow(title: criterion.question, rating: scoreBinding(for: criterion), starSize: 26)
                            }
                        }
                    }

                    Divider()

                    formSection(EvaluationsStrings.writeContentSection) {
                        contentEditor
                    }
                }
                .padding(20)
                .background(
                    Color(uiColor: .secondarySystemGroupedBackground),
                    in: .rect(cornerRadius: 16, style: .continuous)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .scrollDismissesKeyboard(.interactively)
    }

    private func formSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }

    private var contentEditor: some View {
        VStack(alignment: .trailing, spacing: 8) {
            TextField(
                EvaluationsStrings.writeContentPlaceholder,
                text: $viewModel.draft.content,
                axis: .vertical
            )
            .font(.subheadline)
            .lineLimit(6...)
            .focused($isContentFocused)
            .padding(12)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(
                        isContentFocused ? EvaluationDesignColor.accent : Color(uiColor: .separator),
                        lineWidth: isContentFocused ? 1.5 : 1
                    )
            }
            .contentShape(.rect)
            .onTapGesture {
                isContentFocused = true
            }
            .animation(.smooth(duration: 0.2), value: isContentFocused)

            Text(
                EvaluationsStrings.writeContentCounter(
                    viewModel.draft.contentLength,
                    EvaluationDraft.minimumContentLength
                )
            )
            .font(.caption)
            .monospacedDigit()
            .foregroundStyle(viewModel.draft.meetsMinimumContentLength ? EvaluationDesignColor.accent : .secondary)
            .contentTransition(.numericText(value: Double(viewModel.draft.contentLength)))
            .animation(.default, value: viewModel.draft.contentLength)
        }
    }

    @ViewBuilder
    private func semesterPicker(target: EvaluationWriteTarget) -> some View {
        if target.writableSemesterLectures.isEmpty {
            Text(EvaluationsStrings.writeSemesterUnavailable)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            Picker(EvaluationsStrings.writeSemester, selection: $viewModel.draft.semesterLectureID) {
                ForEach(target.semesterLectures) { semesterLecture in
                    Text(semesterTitle(semesterLecture))
                        .tag(Optional(semesterLecture.id))
                        .selectionDisabled(semesterLecture.hasMyEvaluation)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .padding(.vertical, 2)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color(uiColor: .separator))
            }
        }
    }

    private func semesterTitle(_ semesterLecture: SemesterLecture) -> String {
        let title = semesterLecture.quarter.evaluationDisplayText
        return semesterLecture.hasMyEvaluation ? EvaluationsStrings.writeSemesterWritten(title) : title
    }

    private func ratingRow(title: String, rating: Binding<Double?>, starSize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
            EvaluationStarRatingInput(rating: rating, accessibilityLabel: title, starSize: starSize)
        }
    }

    private func scoreBinding(for criterion: EvaluationCriterion) -> Binding<Double?> {
        Binding(
            get: { viewModel.draft.scores[criterion] },
            set: { viewModel.draft.scores[criterion] = $0 }
        )
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            EvaluationWriteScene(lectureID: 1101, onComplete: { _ in })
        }
}
