//
//  EvaluationWriteScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

/// The evaluation form for writing or editing, presented modally so it can be confirmed or discarded as a unit.
///
/// Each part of the form is its own view reading only the fields it shows, so typing the review
/// updates the editor and the toolbar without rebuilding the rest of the form.
struct EvaluationWriteScene: View {
    @State private var viewModel: EvaluationWriteViewModel
    @FocusState private var isContentFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    private let onComplete: (EvaluationID) -> Void

    init(
        lectureID: EvaluationLectureID,
        editing evaluation: LectureEvaluation? = nil,
        onComplete: @escaping (EvaluationID) -> Void
    ) {
        _viewModel = State(initialValue: EvaluationWriteViewModel(lectureID: lectureID, editing: evaluation))
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.targetState {
                case .loading:
                    EvaluationWriteForm(
                        viewModel: viewModel,
                        target: EvaluationPreviewFixtures.writeTarget,
                        isContentFocused: $isContentFocused
                    )
                    .redacted(reason: .placeholder)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                case .loaded(let target):
                    EvaluationWriteForm(viewModel: viewModel, target: target, isContentFocused: $isContentFocused)
                case .failed:
                    EvaluationLoadFailedView(retry: retryLoad)
                }
            }
            .animation(.defaultSpring, value: viewModel.targetState)
            .navigationTitle(
                viewModel.editedEvaluation == nil ? EvaluationsStrings.writeTitle : EvaluationsStrings.editTitle
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    EvaluationWriteCancelButton(viewModel: viewModel, onDismiss: { dismiss() })
                }
                ToolbarItem(placement: .confirmationAction) {
                    EvaluationWriteSubmitButton(viewModel: viewModel, onSubmit: submit)
                }
            }
        }
        .modifier(EvaluationWriteDismissGuard(viewModel: viewModel))
        .analyticsScreen(
            viewModel.editedEvaluation.map { .reviewEdit(evaluationID: $0.id.rawValue) }
                ?? .reviewWrite(evLectureID: viewModel.lectureID.rawValue)
        )
        // Runs on every appearance until the form's target arrives, so a load cut short resumes.
        .task {
            guard viewModel.targetState.value == nil else { return }
            await errorAlertHandler.withAlert {
                try await viewModel.load()
            }
        }
    }

    private func submit() {
        isContentFocused = false
        errorAlertHandler.withAlert {
            guard let evaluationID = try await viewModel.submit() else { return }
            dismiss()
            onComplete(evaluationID)
        }
    }

    private func retryLoad() {
        errorAlertHandler.withAlert {
            try await viewModel.load()
        }
    }
}

// MARK: Toolbar

/// Dismisses right away, or asks first when the form has changes.
private struct EvaluationWriteCancelButton: View {
    let viewModel: EvaluationWriteViewModel
    let onDismiss: () -> Void

    @State private var isDiscardConfirmationPresented = false

    private var isEditing: Bool {
        viewModel.editedEvaluation != nil
    }

    var body: some View {
        Button(EvaluationsStrings.cancel, systemImage: "xmark") {
            if viewModel.hasUnsavedChanges {
                isDiscardConfirmationPresented = true
            } else {
                onDismiss()
            }
        }
        .confirmationDialog(
            isEditing ? EvaluationsStrings.editDiscardTitle : EvaluationsStrings.writeDiscardTitle,
            isPresented: $isDiscardConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(
                isEditing ? EvaluationsStrings.editDiscardConfirm : EvaluationsStrings.writeDiscardConfirm,
                role: .destructive,
                action: onDismiss
            )
            Button(
                isEditing ? EvaluationsStrings.editDiscardKeepEditing : EvaluationsStrings.writeDiscardKeepEditing,
                role: .cancel
            ) {}
        }
    }
}

private struct EvaluationWriteSubmitButton: View {
    let viewModel: EvaluationWriteViewModel
    let onSubmit: () -> Void

    var body: some View {
        switch viewModel.submissionState {
        case .editing:
            Button(EvaluationsStrings.writeSubmit, systemImage: "checkmark", action: onSubmit)
                .tint(EvaluationDesignColor.accent)
                .disabled(!viewModel.canSubmit)
        case .submitting:
            ProgressView()
        }
    }
}

/// Blocks swiping the sheet away while the form has changes. A modifier of its own, so the scene
/// doesn't read the form's fields.
private struct EvaluationWriteDismissGuard: ViewModifier {
    let viewModel: EvaluationWriteViewModel

    func body(content: Content) -> some View {
        content.interactiveDismissDisabled(viewModel.hasUnsavedChanges)
    }
}

// MARK: Form

private struct EvaluationWriteForm: View {
    let viewModel: EvaluationWriteViewModel
    let target: EvaluationWriteTarget
    @FocusState.Binding var isContentFocused: Bool

    /// Scrolled to with a bottom anchor so the whole review editor, including its counter, sits above the keyboard.
    private static let contentEditorID = "contentEditor"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    EvaluationDesignColor.sectionSeparator
                        .frame(height: 8)

                    VStack(alignment: .leading, spacing: 32) {
                        EvaluationWriteFormGroup(title: EvaluationsStrings.writeSemester) {
                            EvaluationWriteSemesterPicker(viewModel: viewModel, target: target)
                        }
                        EvaluationWriteFormGroup(title: EvaluationsStrings.writeOverallSection) {
                            EvaluationWriteRatingFields(viewModel: viewModel)
                        }
                    }
                    .formSectionPadding()

                    EvaluationDesignColor.sectionSeparator
                        .frame(height: 8)

                    EvaluationWriteFormGroup(title: EvaluationsStrings.writeContentSection) {
                        EvaluationWriteContentEditor(viewModel: viewModel, isFocused: $isContentFocused)
                            .id(Self.contentEditorID)
                        if let likeCount = viewModel.editedEvaluation?.like.count, likeCount > 0 {
                            Label(EvaluationsStrings.editLikeResetNotice(likeCount), systemImage: "info.circle")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .formSectionPadding()
                }
            }
            .background(Color(uiColor: .systemBackground))
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: isContentFocused) { _, isFocused in
                guard isFocused else { return }
                revealContentEditor(using: proxy)
            }
            // The keyboard shrinks the safe area after focus moves, so reveal the editor again once it settles.
            .onGeometryChange(for: CGFloat.self) {
                $0.safeAreaInsets.bottom
            } action: { _ in
                guard isContentFocused else { return }
                revealContentEditor(using: proxy)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(target.lecture.title)
                .font(.title3.weight(.bold))
            Text(target.lecture.instructorDisplayText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }

    private func revealContentEditor(using proxy: ScrollViewProxy) {
        withAnimation(.smooth) {
            proxy.scrollTo(Self.contentEditorID, anchor: .bottom)
        }
    }
}

private struct EvaluationWriteFormGroup<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.callout.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            content
        }
    }
}

private struct EvaluationWriteSemesterPicker: View {
    @Bindable var viewModel: EvaluationWriteViewModel
    let target: EvaluationWriteTarget

    var body: some View {
        if !target.semesterLectures.contains(where: viewModel.isSelectable) {
            Text(EvaluationsStrings.writeSemesterUnavailable)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            Menu {
                Picker(EvaluationsStrings.writeSemester, selection: $viewModel.semesterLectureID) {
                    ForEach(target.semesterLectures) { semesterLecture in
                        Text(title(for: semesterLecture))
                            .tag(Optional(semesterLecture.id))
                            .selectionDisabled(!viewModel.isSelectable(semesterLecture))
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selectedTitle)
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .frame(minHeight: 36)
                .overlay {
                    Capsule()
                        .strokeBorder(Color(uiColor: .systemGray5))
                }
                .contentShape(.capsule)
            }
            .accessibilityLabel(EvaluationsStrings.writeSemester)
            .accessibilityValue(selectedTitle)
        }
    }

    private var selectedTitle: String {
        target.semesterLectures
            .first { $0.id == viewModel.semesterLectureID }
            .map(\.quarter.evaluationDisplayText) ?? ""
    }

    private func title(for semesterLecture: SemesterLecture) -> String {
        let title = semesterLecture.quarter.evaluationDisplayText
        return viewModel.isSelectable(semesterLecture) ? title : EvaluationsStrings.writeSemesterWritten(title)
    }
}

/// The overall rating and the four criteria. Each star input reads its own binding,
/// so this view itself reads none of the ratings.
private struct EvaluationWriteRatingFields: View {
    @Bindable var viewModel: EvaluationWriteViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ratingRow(title: EvaluationsStrings.writeOverall, rating: $viewModel.rating, starSize: 32)
            ForEach(EvaluationCriterion.allCases, id: \.self) { criterion in
                ratingRow(title: criterion.question, rating: $viewModel.scores[criterion], starSize: 26)
            }
        }
    }

    private func ratingRow(title: String, rating: Binding<Double?>, starSize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
            EvaluationStarRatingInput(rating: rating, accessibilityLabel: title, starSize: starSize)
        }
    }
}

private struct EvaluationWriteContentEditor: View {
    @Bindable var viewModel: EvaluationWriteViewModel
    @FocusState.Binding var isFocused: Bool
    @ScaledMetric private var editorHeight = 140.0

    var body: some View {
        let contentLength = EvaluationDraft.contentLength(of: viewModel.content)
        VStack(alignment: .trailing, spacing: 8) {
            // A fixed-height editor scrolls inside itself to keep the caret visible while typing.
            PlaceholderTextEditor(
                placeholder: EvaluationsStrings.writeContentPlaceholder,
                text: $viewModel.content
            )
            .font(.subheadline)
            .frame(height: editorHeight)
            .focused($isFocused)
            .accessibilityLabel(EvaluationsStrings.writeContentSection)
            .padding(14)
            .background(
                Color(uiColor: .secondarySystemBackground),
                in: .rect(cornerRadius: 12, style: .continuous)
            )
            .overlay {
                if isFocused {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(EvaluationDesignColor.accent, lineWidth: 1.5)
                }
            }
            .contentShape(.rect)
            // Focuses the editor from its padding too, which the text view itself doesn't cover.
            .onTapGesture {
                isFocused = true
            }
            .animation(.smooth(duration: 0.2), value: isFocused)

            Text(EvaluationsStrings.writeContentCounter(contentLength, EvaluationDraft.minimumContentLength))
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(
                    contentLength >= EvaluationDraft.minimumContentLength ? EvaluationDesignColor.accent : .secondary
                )
                .contentTransition(.numericText(value: Double(contentLength)))
                .animation(.default, value: contentLength)
        }
        .padding(.bottom, 8)
    }
}

extension View {
    fileprivate func formSectionPadding() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            EvaluationWriteScene(lectureID: 1101, onComplete: { _ in })
        }
}

#Preview("Editing") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            EvaluationWriteScene(
                lectureID: 1101,
                editing: EvaluationPreviewFixtures.feed[0].evaluation,
                onComplete: { _ in }
            )
        }
}
