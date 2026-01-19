//
//  ExpandableDiarySummaryCell.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import SharedUIComponents
import SwiftUI
import TimetableInterface

struct ExpandableDiarySummaryCell: View {
    let diaryList: [DiarySummary]
    let onDelete: (String) -> Void

    @State private var isExpanded: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var selectedDiary: DiarySummary?

    private var dateString: String {
        guard let firstDiary = diaryList.first else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: firstDiary.date)
    }

    private var weekdayString: String {
        guard let firstDiary = diaryList.first else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: firstDiary.date)
    }

    private var joinedLectureTitle: String {
        diaryList.map { $0.lectureTitle }.joined(separator: ", ")
    }

    var body: some View {
        VStack(spacing: 8) {
            headerView

            if isExpanded {
                VStack(spacing: 16) {
                    ForEach(diaryList) { diary in
                        diaryCard(diary)
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, isExpanded ? 32 : 16)
        .padding(.horizontal, 20)
        .alert(
            LectureDiaryStrings.lectureDiaryDeleteAlertTitle(selectedDiary?.lectureTitle ?? ""),
            isPresented: $showDeleteAlert
        ) {
            Button(LectureDiaryStrings.lectureDiaryCancel, role: .cancel) {}
            Button(LectureDiaryStrings.lectureDiaryConfirm, role: .destructive) {
                if let diary = selectedDiary {
                    onDelete(diary.id)
                }
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Text(dateString)
                Text(weekdayString)
                Spacer()
            }
            .font(.system(size: 15, weight: .semibold))

            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(joinedLectureTitle)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 14))
                    Spacer()
                    LectureDiaryAsset.chevronRight.swiftUIImage
                        .rotationEffect(.degrees(isExpanded ? -90 : 90))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
    }

    private func diaryCard(_ diary: DiarySummary) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(diary.lectureTitle)
                    .font(.system(size: 14))
                    .foregroundStyle(
                        light: SharedUIComponentsAsset.alternative.swiftUIColor,
                        dark: SharedUIComponentsAsset.assistive.swiftUIColor
                    )
                Spacer()
                Button {
                    selectedDiary = diary
                    showDeleteAlert = true
                } label: {
                    LectureDiaryAsset.trash.swiftUIImage
                }
            }

            VStack(spacing: 6) {
                ForEach(diary.shortQuestionReplies, id: \.question) { reply in
                    DiaryQuestionAnswerRow(question: reply.question, answer: reply.answer)
                }

                if let comment = diary.comment {
                    DiaryQuestionAnswerRow(
                        question: LectureDiaryStrings.lectureDiaryCommentSectionTitle,
                        answer: comment
                    )
                }
            }
        }
        .padding([.horizontal, .top], 16)
        .padding(.bottom, 20)
        .backgroundStyle(
            light: SharedUIComponentsAsset.neutral98.swiftUIColor,
            dark: SharedUIComponentsAsset.groupBackground.swiftUIColor
        )
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview("Single Diary") {
    let diary = DiarySummary(
        id: "1",
        lectureID: "123",
        date: Date(),
        lectureTitle: "시각디자인기초",
        shortQuestionReplies: [
            QuestionReply(question: "수강신청", answer: "널널해요"),
            QuestionReply(question: "드랍여부", answer: "모르겠어요"),
            QuestionReply(question: "수업 첫인상", answer: "두려워요"),
        ],
        comment: "오티 했어용..."
    )

    ExpandableDiarySummaryCell(diaryList: [diary], onDelete: { _ in })
        .padding()
}

#Preview("Multiple Diaries") {
    let diaries = [
        DiarySummary(
            id: "1",
            lectureID: "123",
            date: Date(),
            lectureTitle: "시각디자인기초",
            shortQuestionReplies: [
                QuestionReply(question: "수강신청", answer: "널널해요"),
                QuestionReply(question: "드랍여부", answer: "모르겠어요"),
            ],
            comment: "오티 했어용..."
        ),
        DiarySummary(
            id: "2",
            lectureID: "456",
            date: Date(),
            lectureTitle: "배구",
            shortQuestionReplies: [
                QuestionReply(question: "수강신청", answer: "무난해요"),
                QuestionReply(question: "수업 첫인상", answer: "기대돼요"),
            ],
            comment: nil
        ),
    ]

    ExpandableDiarySummaryCell(diaryList: diaries, onDelete: { _ in })
        .padding()
}
