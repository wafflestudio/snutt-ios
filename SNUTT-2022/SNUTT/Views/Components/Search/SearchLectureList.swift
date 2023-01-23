//
//  SearchLectureList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/04.
//

import SwiftUI

struct SearchLectureList: View {
    let data: [Lecture]
    let fetchMore: () async -> Void
    let bookmarkedLecture: (Lecture) -> Lecture?
    let existingLecture: (Lecture) -> Lecture?
    let bookmarkLecture: (Lecture) async -> Void
    let undoBookmarkLecture: (Lecture) async -> Void
    let getBookmark: () async -> Void
    let addLecture: (Lecture) async -> Void
    let deleteLecture: (Lecture) async -> Void
    let fetchReviewId: (Lecture) async -> String?
    let overwriteLecture: (Lecture) async -> Void
    let preloadReviewWebView: (String) -> Void
    let errorTitle: String
    let errorMessage: String
    @Binding var isLectureOverlapped: Bool
    @Binding var selected: Lecture?
    @Binding var isFirstBookmark: Bool

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(data) { lecture in
                    SearchLectureCell(lecture: lecture,
                                      selected: selected?.id == lecture.id,
                                      bookmarkLecture: bookmarkLecture,
                                      undoBookmarkLecture: undoBookmarkLecture,
                                      getBookmark: getBookmark,
                                      addLecture: addLecture,
                                      deleteLecture: deleteLecture,
                                      fetchReviewId: fetchReviewId,
                                      preloadReviewWebView: preloadReviewWebView,
                                      isBookmarked: bookmarkedLecture(lecture) != nil,
                                      isInTimetable: existingLecture(lecture) != nil,
                                      isFirstBookmark: $isFirstBookmark)
                        .task {
                            if lecture.id == data.last?.id {
                                await fetchMore()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selected?.id != lecture.id {
                                selected = lecture
                            }
                        }
                        .alert(errorTitle, isPresented: $isLectureOverlapped) {
                            Button {
                                Task {
                                    await overwriteLecture(selected!)
                                }
                            } label: {
                                Text("확인")
                            }

                            Button("취소", role: .cancel) {
                                isLectureOverlapped = false
                            }
                        } message: {
                            Text(errorMessage)
                        }
                }
            }
        }

        let _ = debugChanges()
    }
}
