//
//  SearchLectureCell.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/22.
//

import SwiftUI

struct SearchLectureCell: View {
    let viewModel: ViewModel
    let lecture: Lecture
    var selected: Bool

    @State var showingDetailPage = false

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
                        .sheet(isPresented: $showingDetailPage) {
                            NavigationView {
                                LectureDetailScene(viewModel: .init(container: viewModel.container), lecture: lecture, displayMode: .preview)
                            }
                        }

                        Button {} label: {
                            Text("강의평")
                                .frame(maxWidth: .infinity)
                                .font(STFont.details)
                        }

                        Button {
                            Task {
                                await viewModel.addLecture(lecture: lecture)
                            }
                        } label: {
                            Text("+ 추가하기")
                                .frame(maxWidth: .infinity)
                                .font(STFont.details)
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

extension SearchLectureCell {
    class ViewModel: BaseViewModel {
        func addLecture(lecture: Lecture) async {
            do {
                try await services.lectureService.addLecture(lecture: lecture)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}
