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
    let deleteLecture: (Lecture) async -> Void
    let fetchReviewId: (Lecture) async -> String?
    let isInTimetable: Bool

    @State var showingDetailPage = false
    @State private var showReviewWebView: Bool = false
    @State private var reviewId: String? = nil

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
                                showReviewWebView = true

                                // TODO: fix me
                                if let detailId = reviewId {
                                    container?.services.globalUIService.sendDetailWebViewReloadSignal(url: WebViewType.reviewDetail(id: detailId).url)
                                }
                            }
                        } label: {
                            Text("강의평")
                                .frame(maxWidth: .infinity)
                                .font(STFont.details)
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
                            ReviewScene(viewModel: .init(container: container), detailId: $reviewId)
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
