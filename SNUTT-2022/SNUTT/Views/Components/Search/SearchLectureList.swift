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
    let sameLecture: (Lecture) -> Lecture?
    let addLecture: (Lecture) async -> Void
    let deleteLecture: (Lecture) async -> Void
    let fetchReviewId: (Lecture, Binding<String>) async -> Void
    let overwriteLecture: (Lecture) async -> Void
    let errorTitle: String
    let errorMessage: String
    @Binding var isLectureOverlapped: Bool
    @Binding var selected: Lecture?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(data) { lecture in
                    SearchLectureCell(lecture: lecture,
                                      selected: selected?.id == lecture.id,
                                      addLecture: addLecture,
                                      deleteLecture: deleteLecture,
                                      fetchReviewId: fetchReviewId,
                                      isInTimetable: sameLecture(lecture) != nil)
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
