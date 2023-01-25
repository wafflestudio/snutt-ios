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
    let preloadReviewWebView: (String) -> Void
    let isBookmarked: Bool
    let isInTimetable: Bool

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
                        Button {
                            showingDetailPage = true
                        } label: {
                            Text("자세히")
                                .frame(maxWidth: .infinity)
                                .font(STFont.details)
                        }

                        Button {
                            Task {
                                reviewId = await fetchReviewId(lecture)
                                if let detailId = reviewId {
                                    preloadReviewWebView(detailId)
                                    showReviewWebView = true
                                }
                            }
                        } label: {
                            Text("강의평")
                                .frame(maxWidth: .infinity)
                                .font(STFont.details)
                        }

                        if isBookmarked {
                            Button {
                                isUndoBookmarkAlertPresented = true
                            } label: {
                                HStack {
                                    Image("bookmark.mint")
                                    Text("관심강좌")
                                        .font(STFont.details)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .alert("강의를 관심강좌에서 제외하시겠습니까?", isPresented: $isUndoBookmarkAlertPresented) {
                                Button("취소", role: .cancel, action: {})
                                Button("확인", role: .destructive) {
                                    Task {
                                        await undoBookmarkLecture(lecture)
                                        await undoBookmarkLecture(lecture)
                                    }
                                }
                            }
                        } else {
                            Button {
                                Task {
                                    await bookmarkLecture(lecture)
                                    await bookmarkLecture(lecture)
                                }
                            } label: {
                                HStack {
                                    Image("bookmark.white")
                                    Text("관심강좌")
                                        .font(STFont.details)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }

                        if isInTimetable {
                            Button {
                                Task {
                                    await deleteLecture(lecture)
                                }
                            } label: {
                                Text("제거하기")
                                    .frame(maxWidth: .infinity)
                                    .font(STFont.details)
                            }
                        } else {
                            Button {
                                Task {
                                    await addLecture(lecture)
                                }
                            } label: {
                                Text("+ 추가하기")
                                    .frame(maxWidth: .infinity)
                                    .font(STFont.details)
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
