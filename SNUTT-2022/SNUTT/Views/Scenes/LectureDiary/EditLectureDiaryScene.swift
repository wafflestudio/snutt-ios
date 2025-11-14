//
//  EditLectureDiaryScene.swift
//  SNUTT
//
//  Created by 최유림 on 4/26/25.
//

import SwiftUI

struct EditLectureDiaryScene: View {
    @ObservedObject var viewModel: EditLectureDiaryViewModel
    let lecture: Lecture
    @State private var disableButton: Bool = true
    @State private var showNextSession: Bool = false
    @State private var showExitAlert: Bool = false
    @State private var showConfirmView: Bool = false
    @State private var extraReview: String = ""
    
    @State private var classCategoryList: [AnswerOption] = []
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Namespace var review
    
    init(viewModel: EditLectureDiaryViewModel, lecture: Lecture) {
        self.lecture = lecture
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                header(lectureTitle: lecture.title)
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        Group {
                            Spacer().frame(height: 8)
                            classTypeQuestionnaire
                            if showNextSession,
                               let questions = viewModel.lectureQuestionnaire?.questions,
                               !questions.isEmpty {
                                Group {
                                    Spacer().frame(height: 8)
                                    detailQuestionnaireList(questions)
                                        .id(review)
                                    ExtraReviewSection(extraReview: $extraReview)
                                }
                                .onAppear {
                                    withAnimation(.easeIn.delay(0.5)) {
                                        proxy.scrollTo(review, anchor: .top)
                                    }
                                }
                                submitDiaryButton
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .background(colorScheme == .dark ? .black : STColor.lightField)
            
            if showConfirmView {
                LectureDiaryConfirmView(displayMode: .reviewMore) {
                    // TODO: 다른 리뷰 진행
                }
            }
        }
        .animation(.easeInOut, value: showNextSession)
        .alert("강의일기 작성을 중단하시겠습니까?", isPresented: $showExitAlert) {
            Button("확인", role: .destructive) {
                dismiss()
            }
            Button("취소", role: .cancel) {}
        }
        .task {
            await viewModel.getDailyClassTypeList()
        }
    }
}

// MARK: View Components
extension EditLectureDiaryScene {
    @ViewBuilder private func header(lectureTitle: String) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("오늘 수강한 '\(lectureTitle)'에 대한\n의견을 남겨보세요.")
                    .lineHeight(with: STFont.bold17, percentage: 145)
                    .foregroundStyle(.primary)
                Text("더보기 > 강의일기장에서 확인할 수 있어요.")
                    .font(STFont.regular14.font)
                    .foregroundStyle(
                        colorScheme == .dark
                        ? STColor.gray30
                        : STColor.alternative
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image("daily.review.xmark")
                .onTapGesture {
                    showExitAlert = true
                }
        }
        .padding(.top, 44)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(
            colorScheme == .dark ? STColor.groupBackground : .white
        )
        .overlay(Divider().foregroundStyle(STColor.border), alignment: .bottom)
        .shadow(color: .black.opacity(0.02), radius: 12, y: 6)
    }
    
    private var classTypeQuestionnaire: some View {
        VStack(alignment: .leading, spacing: 4) {
            QuestionAnswerSection(
                allowMultipleAnswers: true,
                questionItem: .init(
                    question: "오늘 무엇을 했나요?",
                    subQuestion: "중복 가능",
                    options: viewModel.dailyClassTypeList
                )
            ) { options in
                classCategoryList = options
            }
            if !showNextSession {
                HStack {
                    Spacer()
                    Button {
                        Task {
                            if await viewModel.fetchDiaryQuestionnaire(for: lecture.referenceId, with: classCategoryList) {
                                showNextSession = true
                            }
                        }
                    } label: {
                        Text("완료")
                            .font(STFont.semibold14.font)
                            .foregroundStyle(
                                classCategoryList.isEmpty
                                ? STColor.gray30
                                : (
                                    colorScheme == .dark
                                    ? STColor.darkMint1
                                    : STColor.darkMint2
                                )
                            )
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .disabled(classCategoryList.isEmpty)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 20)
        .background(
            colorScheme == .dark ? STColor.groupBackground : .white
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private func detailQuestionnaireList(_ questions: [QuestionItem]) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(questions, id: \.question) { questionItem in
                QuestionAnswerSection(
                    questionItem: questionItem
                ) { options in
                    
                }
                if questionItem.question != questions.last?.question {
                    Divider().frame(height: 0.8)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(STColor.lightest)
                }
            }
            
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 28)
        .background(
            colorScheme == .dark ? STColor.groupBackground : .white
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var submitDiaryButton: some View {
        HStack {
            Spacer()
            RoundedRectButton(
                label: "다음",
                type: .medium,
                disabled: disableButton
            ) {
                Task {
                    // TODO: Submit Diary
                }
            }
            .frame(width: 122)
        }
        .padding(.top, 4)
        .padding(.bottom, 40)
    }
}

extension EditLectureDiaryScene {
    final class EditLectureDiaryViewModel: BaseViewModel, ObservableObject {
        
        @Published var dailyClassTypeList: [AnswerOption] = []
        @Published var lectureQuestionnaire: DiaryQuestionnaire?
        
        override init(container: DIContainer) {
            super.init(container: container)
        }
        
        func getDailyClassTypeList() async {
            do {
                dailyClassTypeList = try await diaryService.fetchDailyClassTypeList()
                print(dailyClassTypeList)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
        
        func fetchDiaryQuestionnaire(for lectureId: String, with dailyClassTypes: [AnswerOption]) async -> Bool {
            do {
                lectureQuestionnaire = try await diaryService.fetchQuestionnaire(for: lectureId, from: dailyClassTypes)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }
        
        func submitDiary(diary: DiaryDto) async -> Bool {
            do {
                try await diaryService.submitDiary(diary)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }
        
        private var diaryService: DiaryServiceProtocol {
            services.diaryService
        }
    }
}

#Preview {
    EditLectureDiaryScene(
        viewModel: .init(container: .preview),
        lecture: .preview
    )
}
