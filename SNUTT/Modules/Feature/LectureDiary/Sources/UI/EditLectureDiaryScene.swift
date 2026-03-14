#if FEATURE_LECTURE_DIARY
    //
    //  EditLectureDiaryScene.swift
    //  SNUTT
    //
    //  Copyright © 2025 wafflestudio.com. All rights reserved.
    //

    import Dependencies
    import LectureDiaryInterface
    import SharedUIComponents
    import SwiftUI

    extension View {
        public func overlayLectureDiarySheet(
            _ item: Binding<DiaryEditContext?>,
            onDismiss: @escaping () -> Void = {}
        ) -> some View {
            fullScreenCover(item: item, onDismiss: onDismiss) { context in
                EditLectureDiaryScene(
                    lectureID: context.lectureID,
                    lectureTitle: context.lectureTitle
                )
            }
        }
    }

    struct EditLectureDiaryScene: View {

        @Environment(\.dismiss) private var dismiss
        @Environment(\.errorAlertHandler) private var errorAlertHandler

        @Dependency(\.notificationCenter) private var notificationCenter

        @State private var viewModel: EditLectureDiaryViewModel
        @State private var showCancelAlert = false
        @State private var showConfirmView = false
        @State private var showNextSection = false
        @State private var detailQuestionPosition: Int?
        @State private var shouldPostNotificationOnDismiss = false

        public init(lectureID: String, lectureTitle: String) {
            _viewModel = State(
                initialValue: EditLectureDiaryViewModel(
                    lectureID: lectureID,
                    lectureTitle: lectureTitle
                )
            )
        }

        private var isClassTypeConfirmEnabled: Bool {
            !viewModel.selectedClassTypes.selected.isEmpty
        }

        public var body: some View {
            ZStack(alignment: .top) {
                Rectangle()
                    .foregroundStyle(Color.sceneBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView

                    GeometryReader { proxy in
                        ScrollView {
                            VStack(spacing: 16) {
                                step1ClassTypeSelection
                                    .id(0)

                                if showNextSection {
                                    step2QuestionAnswers
                                        .id(1)
                                    extraCommentSection
                                    submitButton
                                    Spacer()
                                } else {
                                    Spacer(minLength: 0)
                                    setNotificationButton
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                            .frame(minHeight: proxy.size.height)
                        }
                        .scrollPosition(id: $detailQuestionPosition, anchor: .top)
                        .animation(.easeInOut(duration: 0.3), value: detailQuestionPosition)
                    }
                }
            }
            .task {
                await viewModel.getClassTypes()
            }
            .fullScreenCover(isPresented: $showConfirmView) {
                LectureDiaryConfirmView(displayMode: .reviewDone)
            }
            .onChange(of: showConfirmView) { _, isShowing in
                if !isShowing { dismiss() }
            }
            .onDisappear {
                if shouldPostNotificationOnDismiss {
                    notificationCenter.post(NavigateToPushNotificationSettingsMessage())
                }
            }
        }

        private var headerView: some View {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LectureDiaryStrings.lectureDiaryEditHeaderTitle(viewModel.lectureTitle))
                            .font(.systemFont(ofSize: 17, weight: .bold), lineHeightMultiple: 1.45)

                        Text(LectureDiaryStrings.lectureDiaryEditHeaderSubtitle)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.subtitleForeground)
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
                .background(Color.cardBackground)
            }
            .overlay(alignment: .bottom) {
                Divider()
                    .frame(height: 0.4)
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
                HStack {
                    Text(LectureDiaryStrings.lectureDiaryEditClassTypeQuestion)
                        .font(.system(size: 15, weight: .semibold))
                    Text(LectureDiaryStrings.lectureDiaryEditClassTypeMultiple)
                        .font(.system(size: 13))
                        .foregroundStyle(SharedUIComponentsAsset.alternative.swiftUIColor)
                }

                WrappedOptionChipList(
                    selectedOptions: Binding(
                        get: {
                            viewModel.classTypes.filter { viewModel.selectedClassTypes.selected.contains($0.content) }
                        },
                        set: { viewModel.selectedClassTypes = .init(selected: $0.map(\.content)) }
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
                        showNextSection = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            detailQuestionPosition = 1
                        }
                    } label: {
                        Text(LectureDiaryStrings.lectureDiaryEditDone)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(
                                isClassTypeConfirmEnabled
                                    ? Color.enabledButtonLabel
                                    : Color.disabledButtonLabel
                            )
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .disabled(!isClassTypeConfirmEnabled)
                }
            }
            .padding([.horizontal, .bottom], 20)
            .padding(.top, 24)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                                .foregroundStyle(Color.questionDivider)
                        }
                    }
                }
                .padding(20)
                .background(Color.cardBackground)
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
                    submitDiary()
                }
                .frame(width: 122)
            }
            .padding(.top, 4)
            .padding(.bottom, 40)
        }

        private var setNotificationButton: some View {
            VStack(spacing: 2) {
                Text(LectureDiaryStrings.lectureDiaryEditSetNotificationLabel)
                    .font(.systemFont(ofSize: 13), lineHeightMultiple: 1.45)
                    .multilineTextAlignment(.center)
                Button {
                    shouldPostNotificationOnDismiss = true
                    dismiss()
                } label: {
                    HStack(spacing: 0) {
                        Text(LectureDiaryStrings.lectureDiaryEditSetNotificationButtonLabel)
                            .font(.system(size: 14, weight: .medium))
                        LectureDiaryAsset.chevronRightDark.swiftUIImage
                    }
                }
                .padding(.vertical, 6)
                .padding(.leading, 12)
                .padding(.trailing, 8)
            }
            .foregroundStyle(Color.setNotificationLabel)
            .padding(.bottom, 16)
        }

        private func submitDiary() {
            errorAlertHandler.withAlert {
                try await viewModel.submitDiary()
                showConfirmView = true
            }
        }
    }

    #Preview {
        EditLectureDiaryScene(lectureID: "1", lectureTitle: "컴퓨터의 개념 및 실습")
    }
#endif
