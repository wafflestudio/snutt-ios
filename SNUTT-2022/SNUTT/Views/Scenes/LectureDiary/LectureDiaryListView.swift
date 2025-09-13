//
//  LectureDiaryListView.swift
//  SNUTT
//
//  Created by 최유림 on 5/28/25.
//

import SwiftUI

struct LectureDiaryListView: View {
    
    var reviewList: [DailyReview] = []
    @State private var selectedSemester: String = ""
    
    @Environment(\.colorScheme) private var colorScheme
    
    var semesterList: [String] {
        Set(reviewList.map { String($0.semester) }).sorted(by: { $1 < $0 })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: Semester
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(semesterList, id: \.self) { semester in
                        SemesterChip(
                            semester: semester,
                            isSelected: semester == selectedSemester
                        ) {
                            selectedSemester = semester
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 12)
            .padding(.horizontal, 20)
            
            // MARK: DailyReview list
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(reviewList, id: \.self) { review in
                        ExpandableDailyReview(reviewList: [review])
                    }
                }
            }
        }
        .navigationTitle("강의 일기장")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension LectureDiaryListView {
    struct SemesterChip: View {
        
        let semester: String
        let isSelected: Bool
        let selected: () -> Void
        
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            Button {
                selected()
            } label: {
                Text(semester)
                    .font(
                        isSelected
                        ? .system(size: 15, weight: .semibold)
                        : .system(size: 15)
                    )
                    .foregroundStyle(semesterChipForeground(isSelected))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(semesterChipBackground(isSelected))
                    .clipShape(Capsule())
            }
        }
        
        private func semesterChipForeground(_ selected: Bool) -> Color {
            selected
            ? .white
            : (colorScheme == .dark ? STColor.assistive : STColor.alternative)
        }
        
        private func semesterChipBackground(_ selected: Bool) -> Color {
            switch colorScheme {
            case .dark:
                selected ? STColor.darkMint1 : STColor.neutral5
            default:
                selected ? STColor.cyan : STColor.neutral98
            }
        }
    }
    
    struct ExpandableDailyReview: View {
        
        let reviewList: [DailyReview]
        @State private var isExpanded: Bool = false
        @State private var showDeleteReviewAlert: Bool = false
        @State private var selectedReview: DailyReview?
        
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            VStack(spacing: 8) {
                // MARK: Header
                VStack(spacing: 0) {
                    HStack(spacing: 6) {
                        // TODO: Date, weekday (15, semibold, .primary)
                    }
                    Button {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            // TODO: Extract lecture names
                            Spacer()
                            Image("daily.review.chevron.right")
                                .rotationEffect(isExpanded ? .degrees(-90) : .degrees(90))
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // MARK: Detail
                if isExpanded {
                    VStack(spacing: 16) {
                        ForEach(reviewList, id: \.self) { review in
                            VStack(spacing: 6) {
                                // MARK: Review content
                                VStack(spacing: 16) {
                                    HStack {
                                        Text(review.lectureTitle)
                                            .font(.system(size: 14))
                                            .foregroundStyle(
                                                colorScheme == .dark
                                                ? STColor.assistive
                                                : STColor.alternative
                                            )
                                        Spacer()
                                        Button {
                                            selectedReview = review
                                            showDeleteReviewAlert = true
                                        } label: {
                                            Image("daily.review.trash")
                                        }
                                    }
                                    
                                    // MARK: Review detail
                                    VStack(spacing: 6) {
                                        ForEach(Array(review.content.keys), id: \.self) { title in
                                            ReviewContentRow(title: title, content: review.content[title]!)
                                        }
                                        if let comment = review.comment {
                                            ReviewContentRow(title: "남기고 싶은 말", content: comment)
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
                }
            }
            .padding(.top, 16)
            .padding(.bottom, isExpanded ? 32 : 16)
            .padding(.horizontal, 20)
            .alert("", isPresented: $showDeleteReviewAlert) {
                Button("취소", role: .cancel) {}
                Button("확인", role: .destructive) {
                    // TODO: Delete review
                }
            } message: {
                if let lectureTitle = selectedReview?.lectureTitle {
                    Text("'\(lectureTitle)' 강의일기를 삭제하시겠습니까?")
                }
            }
        }
    }
    
    struct ReviewContentRow: View {
        
        let title: String
        let content: String
        
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            HStack(alignment: .top, spacing: 16) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(
                        colorScheme == .dark
                        ? STColor.alternative
                        : STColor.assistive
                    )
                    .frame(width: 80, alignment: .leading)
                Text(content)
                    .font(.system(size: 14))
                    .foregroundStyle(
                        colorScheme == .dark
                        ? STColor.assistive
                        : STColor.darkerGray
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    NavigationView {
        LectureDiaryListView(reviewList: [.debug])
    }
}
