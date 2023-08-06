//
//  SearchLectureCell.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/22.
//

import SwiftUI

struct SearchLectureCell: View {
    let lecture: Lecture
    let selected: Bool
    let bookmarkLecture: (Lecture) async -> Void
    let undoBookmarkLecture: (Lecture) async -> Void
    let addLecture: (Lecture) async -> Void
    let deleteLecture: (Lecture) async -> Void
    let fetchReviewId: (Lecture) async -> String?
    let preloadReviewWebView: @MainActor (String) -> Void
    let addVacancyLecture: (Lecture) async -> Void
    let deleteVacancyLecture: (Lecture) async -> Void
    let isBookmarked: Bool
    let isInTimetable: Bool
    let isVacancyNotificationEnabled: Bool

    @State var showingDetailPage = false
    @State private var showReviewWebView: Bool = false
    @State private var reviewId: String? = nil
    @State private var isUndoBookmarkAlertPresented = false

    @Environment(\.dependencyContainer) var container: DIContainer?

    var body: some View {
        ZStack {
            if selected {
                STColor.searchListForeground
            }

            VStack(spacing: 8) {
                // title
                LectureHeaderRow(lecture: lecture)

                // details
                if lecture.isCustom {
                    LectureDetailRow(imageName: "tag.white", text: "")
                } else {
                    LectureDetailRow(imageName: "tag.white", text: "\(lecture.department), \(lecture.academicYear)")
                }
                LectureDetailRow(imageName: "clock.white", text: lecture.preciseTimeString)

                LectureDetailRow(imageName: "map.white", text: lecture.placesString)

                LectureDetailRow(imageName: "ellipsis.white", text: lecture.remark)

                if selected {
                    Spacer().frame(height: 5)
                    

                    HStack {
                        LectureCellActionButton(
                            icon: .asset(name: "search.detail"),
                            text: "자세히") {
                                showingDetailPage = true
                            }

                        LectureCellActionButton(
                            icon: .asset(name: "search.evaluation"),
                            text: "강의평") {
                                reviewId = await fetchReviewId(lecture)
                                if let detailId = reviewId {
                                    preloadReviewWebView(detailId)
                                    showReviewWebView = true
                                }
                            }

                        LectureCellActionButton(
                            icon: .asset(name: isBookmarked ? "search.bookmark.fill" : "search.bookmark"),
                            text: "관심강좌") {
                                if isBookmarked {
                                    isUndoBookmarkAlertPresented = true
                                } else {
                                    await bookmarkLecture(lecture)
                                }
                            }
                            .alert("강의를 관심강좌에서 제외하시겠습니까?", isPresented: $isUndoBookmarkAlertPresented) {
                                Button("취소", role: .cancel, action: {})
                                Button("확인", role: .destructive) {
                                    Task {
                                        await undoBookmarkLecture(lecture)
                                    }
                                }
                            }

                        LectureCellActionButton(
                            icon: .asset(name: isVacancyNotificationEnabled ? "search.vacancy.fill" : "search.vacancy"),
                            text: "빈자리알림") {
                                if isVacancyNotificationEnabled {
                                    await deleteVacancyLecture(lecture)
                                } else {
                                    await addVacancyLecture(lecture)
                                }
                            }

                        LectureCellActionButton(
                            icon: .asset(name: isInTimetable ? "search.remove.fill" : "search.add"),
                            text: isInTimetable ? "제거하기" : "추가하기") {
                                if isInTimetable {
                                    await deleteLecture(lecture)
                                } else {
                                    await addLecture(lecture)
                                }
                            }
                    }
                    /// This `sheet` modifier should be called on `HStack` to prevent animation glitch when `dismiss`ed.
                    .sheet(isPresented: $showReviewWebView) {
                        if let container = container {
                            ReviewScene(viewModel: .init(container: container), isMainWebView: false, detailId: $reviewId)
                                .id(reviewId)
                        }
                    }
                    .sheet(isPresented: $showingDetailPage) {
                        if let container = container {
                            NavigationView {
                                LectureDetailScene(viewModel: .init(container: container), lecture: lecture, displayMode: .preview)
                            }
                        }
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
        }

        let _ = debugChanges()
    }
}
