//
//  ExpandableDiarySummaryCell.swift
//  SNUTT
//
//  Created by 최유림 on 11/2/25.
//

import SwiftUI

struct ExpandableDiarySummaryCell: View {
    
    let diaryList: [DiarySummary]
    @State private var isExpanded: Bool = false
    @State private var showDeleteDiaryAlert: Bool = false
    @State private var selectedDiary: DiarySummary?
    
    let deleteDiary: (String) -> Void
    
    private var joinedLectureTitle: String {
        diaryList.map { $0.lectureTitle }.joined(separator: ", ")
    }
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            diarySummaryHeader
            if isExpanded {
                VStack(spacing: 16) {
                    ForEach(diaryList, id: \.id) { diary in
                        diarySummaryCard(diary) {
                            selectedDiary = diary
                            showDeleteDiaryAlert = true
                        }
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, isExpanded ? 32 : 16)
        .padding(.horizontal, 20)
        .alert(
            Text("'\(selectedDiary?.lectureTitle ?? "")' 강의일기를 삭제하시겠습니까?"),
            isPresented: $showDeleteDiaryAlert
        ) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                if let selectedDiary = selectedDiary {
                    deleteDiary(selectedDiary.id)
                }
            }
        }
    }
    
    private var diarySummaryHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                if let diary = diaryList.first {
                    Text(diary.dateString)
                    Text(diary.weekdayString)
                    Spacer()
                }
            }
            .font(STFont.semibold15.font)
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(joinedLectureTitle)
                        .foregroundStyle(STColor.alternative)
                        .font(STFont.regular14.font)
                    Spacer()
                    Image("daily.review.chevron.right")
                        .rotationEffect(isExpanded ? .degrees(-90) : .degrees(90))
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    @ViewBuilder
    private func diarySummaryCard(
        _ diary: DiarySummary,
        _ onTap: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 6) {
            VStack(spacing: 16) {
                HStack {
                    Text(diary.lectureTitle)
                        .font(STFont.regular14.font)
                        .foregroundStyle(
                            colorScheme == .dark
                            ? STColor.assistive
                            : STColor.alternative
                        )
                    Spacer()
                    Button {
                        onTap()
                    } label: {
                        Image("daily.review.trash")
                    }
                }
                VStack(spacing: 6) {
                    ForEach(diary.shortQuestionReplies, id: \.question) {
                        DiaryQuestionAnswerRow(question: $0.question, answer: $0.answer)
                    }
                    if let comment = diary.comment {
                        DiaryQuestionAnswerRow(question: "남기고 싶은 말", answer: comment)
                    }
                }
            }
            .padding([.horizontal, .top], 16)
            .padding(.bottom, 20)
            .background(
                colorScheme == .dark
                ? STColor.groupBackground
                : STColor.neutral98
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
