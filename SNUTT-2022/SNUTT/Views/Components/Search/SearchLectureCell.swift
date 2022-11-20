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
    let addLecture: (Lecture) async -> Void
    let fetchReviewId: (Lecture, Binding<String>) async -> Void

    @State var showingDetailPage = false
    @State private var showReviewWebView: Bool = false
    @State private var reviewId: String = ""

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
                    LectureDetailRow(imageName: "tag.white", text: "(없음)")
                } else {
                    LectureDetailRow(imageName: "tag.white", text: "\(lecture.department), \(lecture.academicYear)")
                }
                LectureDetailRow(imageName: "clock.white", text: lecture.startDateTimeString.isEmpty ? "(없음)" : lecture.startDateTimeString)

                LectureDetailRow(imageName: "map.white", text: lecture.timePlaces.isEmpty ? "(없음)" : lecture.timePlaces.map { $0.place }.joined(separator: "/"))

                LectureDetailRow(imageName: "ellipsis.white", text: lecture.remark.isEmpty ? "(없음)" : lecture.remark)

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
                                await fetchReviewId(lecture, $reviewId)
                                showReviewWebView = true
                            }
                        } label: {
                            Text("강의평")
                                .frame(maxWidth: .infinity)
                                .font(STFont.details)
                        }
                        .sheet(isPresented: $showReviewWebView) {
                            if let container = container {
                                ReviewScene(viewModel: .init(container: container), detailId: $reviewId)
                            }
                        }

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
                    /// This `sheet` modifier should be called on `HStack` to prevent animation glitch when `dismiss`ed.
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
