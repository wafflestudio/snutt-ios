//
//  EditLectureDiaryScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct EditLectureDiaryScene: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditLectureDiaryViewModel
    @State private var showCancelAlert = false
    @State private var showConfirmView = false
    @State private var showNextSection = false

    public init(lectureID: String, lectureTitle: String) {
        _viewModel = State(initialValue: EditLectureDiaryViewModel(lectureID: lectureID, lectureTitle: lectureTitle))
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                ScrollView {
                    VStack(spacing: 16) {
                        step1ClassTypeSelection

                        if showNextSection {
                            step2QuestionAnswers
                            extraCommentSection
                            submitButton
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
        }
        .task {
            await viewModel.loadQuestionnaire()
        }
        .fullScreenCover(isPresented: $showConfirmView) {
            LectureDiaryConfirmView(displayMode: .reviewDone)
        }
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("오늘 수강한 '\(viewModel.lectureTitle)'에 대한")
                        .font(.system(size: 17, weight: .bold))
                    Text("의견을 남겨보세요.")
                        .font(.system(size: 17, weight: .bold))

                    Text("더보기 > 강의일기장에서 확인할 수 있어요.")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }

                Spacer()

                Button {
                    showCancelAlert = true
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 44)
            .padding(.bottom, 24)
            .background(Color(.systemBackground))

            Divider()
        }
        .shadow(color: .black.opacity(0.02), radius: 12, y: 6)
        .alert("강의일기 작성을 중단하시겠습니까?", isPresented: $showCancelAlert) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                dismiss()
            }
        }
    }

    private var step1ClassTypeSelection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("오늘 무엇을 했나요?")
                    .font(.system(size: 15, weight: .semibold))
                Text("중복 가능")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            // TODO: Load actual class types from API
            let classTypes = ["이론수업", "토론수업", "발표수업", "실습수업", "과제발표", "퀴즈"]
            let options = classTypes.enumerated().map { index, type in
                AnswerOption(id: "\(index)", content: type)
            }

            WrappedOptionChipList(
                selectedOptions: Binding(
                    get: { options.filter { viewModel.selectedClassTypes.contains($0.content) } },
                    set: { viewModel.selectedClassTypes = $0.map(\.content) }
                ),
                answerOptions: options,
                allowMultiple: true
            )

            HStack {
                Spacer()
                Button("완료") {
                    withAnimation {
                        showNextSection = true
                    }
                    // Scroll to next section
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // TODO: Scroll to step 2
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.selectedClassTypes.isEmpty)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var step2QuestionAnswers: some View {
        if case let .loaded(questions) = viewModel.questionnaireState {
            VStack(spacing: 20) {
                ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
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

                    if index < questions.count - 1 {
                        Divider()
                            .frame(height: 0.8)
                            .foregroundStyle(Color.gray.opacity(0.2))
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
            Button("다음") {
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
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSubmit)
            .frame(width: 122)
        }
        .padding(.top, 4)
        .padding(.bottom, 40)
    }
}

#Preview {
    EditLectureDiaryScene(lectureID: "1", lectureTitle: "시각디자인기초")
}
