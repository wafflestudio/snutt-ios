//
//  EditLectureDiaryScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

extension View {
    public func overlayLectureDiarySheet(lectureId: String, lectureTitle: String) -> some View {
        overlay {
            EditLectureDiaryScene(lectureID: lectureId, lectureTitle: lectureTitle)
        }
    }
}

struct EditLectureDiaryScene: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditLectureDiaryViewModel
    @State private var showCancelAlert = false
    @State private var showConfirmView = false
    @State private var showNextSection = false
    @State private var detailQuestionPosition: Int?

    public init(lectureID: String, lectureTitle: String) {
        _viewModel = State(
            initialValue: EditLectureDiaryViewModel(
                lectureID: lectureID,
                lectureTitle: lectureTitle
            )
        )
    }

    private var isClassTypeConfirmEnabled: Bool {
        !viewModel.selectedClassTypes.isEmpty
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundStyle(
                    light: SharedUIComponentsAsset.lightField.swiftUIColor,
                    dark: .black
                )
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                ScrollView {
                    VStack(spacing: 16) {
                        step1ClassTypeSelection
                            .id(0)

                        if showNextSection {
                            step2QuestionAnswers
                                .id(1)
                            extraCommentSection
                            submitButton
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
                .scrollPosition(id: $detailQuestionPosition, anchor: .top)
                .animation(.easeInOut(duration: 0.3), value: detailQuestionPosition)
            }
        }
        .task {
            await viewModel.getClassTypes()
        }
        .fullScreenCover(isPresented: $showConfirmView) {
            LectureDiaryConfirmView(displayMode: .reviewDone)
        }
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LectureDiaryStrings.lectureDiaryEditHeaderTitle(viewModel.lectureTitle))
                        .lineHeight(with: .systemFont(ofSize: 17, weight: .bold), percentage: 145)

                    Text(LectureDiaryStrings.lectureDiaryEditHeaderSubtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(
                            light: SharedUIComponentsAsset.alternative.swiftUIColor,
                            dark: SharedUIComponentsAsset.gray30.swiftUIColor
                        )
                }

                Spacer()

                Button {
                    showCancelAlert = true
                } label: {
                    LectureDiaryAsset.xmark.swiftUIImage
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 44)
            .padding(.bottom, 24)
            .backgroundStyle(
                light: .white,
                dark: SharedUIComponentsAsset.groupBackground.swiftUIColor
            )

            Divider().foregroundStyle(SharedUIComponentsAsset.border.swiftUIColor)
        }
        .shadow(color: .black.opacity(0.02), radius: 12, y: 6)
        .alert(
            LectureDiaryStrings.lectureDiaryEditCancelAlert,
            isPresented: $showCancelAlert
        ) {
            Button(LectureDiaryStrings.lectureDiaryCancel, role: .cancel) {}
            Button(LectureDiaryStrings.lectureDiaryConfirm, role: .destructive) {
                dismiss()
            }
        }
    }

    private var step1ClassTypeSelection: some View {
        VStack(alignment: .leading, spacing: 16) {
            var lightLabelColor: Color {
                isClassTypeConfirmEnabled
                    ? SharedUIComponentsAsset.darkMint2.swiftUIColor
                    : SharedUIComponentsAsset.gray30.swiftUIColor
            }

            var darkLabelColor: Color {
                isClassTypeConfirmEnabled
                    ? SharedUIComponentsAsset.darkMint1.swiftUIColor
                    : SharedUIComponentsAsset.gray30.swiftUIColor
            }

            HStack {
                Text(LectureDiaryStrings.lectureDiaryEditClassTypeQuestion)
                    .font(.system(size: 15, weight: .semibold))
                Text(LectureDiaryStrings.lectureDiaryEditClassTypeMultiple)
                    .font(.system(size: 13))
                    .foregroundStyle(SharedUIComponentsAsset.alternative.swiftUIColor)
            }

            WrappedOptionChipList(
                selectedOptions: Binding(
                    get: { viewModel.classTypes.filter { viewModel.selectedClassTypes.contains($0.content) } },
                    set: { viewModel.selectedClassTypes = $0.map(\.content) }
                ),
                answerOptions: viewModel.classTypes,
                allowMultiple: true
            )

            HStack {
                Spacer()
                Button {
                    Task {
                        await viewModel.loadQuestionnaire()
                    }
                    withAnimation {
                        showNextSection = true
                    }
                    showNextSection = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        detailQuestionPosition = 1
                    }
                } label: {
                    Text(LectureDiaryStrings.lectureDiaryEditDone)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(
                            light: lightLabelColor,
                            dark: darkLabelColor
                        )
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .disabled(!isClassTypeConfirmEnabled)
            }
        }
        .padding([.horizontal, .bottom], 20)
        .padding(.top, 24)
        .backgroundStyle(
            light: .white,
            dark: SharedUIComponentsAsset.groupBackground.swiftUIColor
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 20, x: 12, y: 6)
    }

    @ViewBuilder
    private var step2QuestionAnswers: some View {
        if case .loaded(let questions) = viewModel.questionnaireState {
            VStack(spacing: 20) {
                ForEach(questions, id: \.id) { question in
                    QuestionAnswerSection(
                        questionItem: question,
                        allowMultipleAnswers: false,
                        onAnswerSelected: { selectedOptions in
                            if let firstOption = selectedOptions.first,
                                let answerIndex = question.options.firstIndex(of: firstOption)
                            {
                                viewModel.selectAnswer(questionID: question.id, answerIndex: answerIndex)
                            }
                        }
                    )

                    if question.id != questions.last?.id {
                        Divider()
                            .frame(height: 0.8)
                            .foregroundStyle(
                                light: SharedUIComponentsAsset.lightLine.swiftUIColor,
                                dark: SharedUIComponentsAsset.alternative.swiftUIColor.opacity(0.4)
                            )
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var extraCommentSection: some View {
        ExtraReviewSection(extraReview: $viewModel.extraComment)
    }

    private var submitButton: some View {
        HStack {
            Spacer()
            RoundedRectButton(
                label: LectureDiaryStrings.lectureDiaryEditNext,
                type: .medium,
                disabled: !viewModel.canSubmit
            ) {
                Task {
                    do {
                        try await viewModel.submitDiary()
                        showConfirmView = true
                    } catch {
                        // TODO: Show error alert
                        print("Failed to submit diary: \(error)")
                    }
                }
            }
            .frame(width: 122)
        }
        .padding(.top, 4)
        .padding(.bottom, 40)
    }
}

#Preview {
    EditLectureDiaryScene(lectureID: "1", lectureTitle: "컴퓨터의 개념 및 실습")
}
