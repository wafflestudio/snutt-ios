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
    let addLecture: (Lecture) async -> Void
    let fetchReviewId: (Lecture, Binding<String>) async -> Void
    let overwriteLecture: (Lecture) async -> Void
    let errorTitle: String
    let errorMessage: String
    @Binding var isLectureOverlapped: Bool
    @Binding var isErrorAlertPresented: Bool
    @Binding var selected: Lecture?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(data) { lecture in
                    SearchLectureCell(lecture: lecture,
                                      selected: selected?.id == lecture.id,
                                      addLecture: addLecture,
                                      fetchReviewId: fetchReviewId)
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
                        .alert(errorTitle, isPresented: $isErrorAlertPresented) {
                            Button {
                                if isLectureOverlapped {
                                    Task {
                                        await overwriteLecture(lecture)
                                    }
                                }
                            } label: {
                                Text("확인")
                            }
                            
                            if isLectureOverlapped {
                                Button("취소", role: .cancel) {
                                    isLectureOverlapped.toggle()
                                }
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
