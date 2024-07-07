//
//  ExpandableLectureCell.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/12/17.
//

import Combine
import SwiftUI

struct ExpandableLectureCell: View {
    @ObservedObject var viewModel: ViewModel

    let lecture: Lecture
    let isSelected: Bool
    let isBookmarked: Bool
    let isInCurrentTimetable: Bool
    let isVacancyNotificationEnabled: Bool

    @State private var isDetailPagePresented = false
    @State private var isReviewWebViewPresented = false
    @State private var isRemoveBookmarkAlertPresented = false
    @State private var reviewDetailId: Int?

    var body: some View {
        ZStack {
            if isSelected {
                STColor.searchListForeground
            }

            VStack(spacing: 8) {
                LectureHeaderRow(lecture: lecture)
                HStack {
                    if lecture.isCustom {
                        LectureDetailRow(imageName: "tag.white", text: "")
                    } else {
                        LectureDetailRow(imageName: "tag.white", text: "\(lecture.department), \(lecture.academicYear)")
                    }
                    HStack(spacing: 2) {
                        Image("search.rating.star")
                        if let evLecture = lecture.evLecture {
                            Text("\(evLecture.avgRatingString) (\(evLecture.evaluationCount))")
                                .foregroundColor(.white.opacity(0.7))
                                .font(STFont.details)
                        }
                    }
                }
                LectureDetailRow(imageName: "clock.white", text: lecture.preciseTimeString)

                LectureDetailRow(imageName: "map.white", text: lecture.placesString)

                LectureDetailRow(imageName: "ellipsis.white", text: lecture.remark)

                if isSelected {
                    Spacer().frame(height: 5)

                    HStack {
                        LectureCellActionButton(
                            icon: .asset(name: "search.detail"),
                            text: "자세히"
                        ) {
                            isDetailPagePresented = true
                        }

                        LectureCellActionButton(
                            icon: .asset(name: "search.evaluation"),
                            text: "강의평"
                        ) {
                            if let evLectureId = lecture.evLecture?.evLectureId {
                                viewModel.reloadReviewWebView(evLectureId: evLectureId)
                                isReviewWebViewPresented = true
                            }
                        }

                        LectureCellActionButton(
                            icon: .asset(name: isBookmarked ? "search.bookmark.fill" : "search.bookmark"),
                            text: "관심강좌"
                        ) {
                            if isBookmarked {
                                isRemoveBookmarkAlertPresented = true
                            } else {
                                await viewModel.addBookmarkLecture(lecture)
                            }
                        }
                        .alert("강의를 관심강좌에서 제외하시겠습니까?", isPresented: $isRemoveBookmarkAlertPresented) {
                            Button("취소", role: .cancel, action: {})
                            Button("확인", role: .destructive) {
                                Task {
                                    await viewModel.removeBookmarkLecture(lecture)
                                }
                            }
                        }

                        LectureCellActionButton(
                            icon: .asset(name: isVacancyNotificationEnabled ? "search.vacancy.fill" : "search.vacancy"),
                            text: "빈자리알림"
                        ) {
                            if isVacancyNotificationEnabled {
                                await viewModel.removeVacancyLecture(lecture)
                            } else {
                                await viewModel.addVacancyLecture(lecture)
                            }
                        }

                        LectureCellActionButton(
                            icon: .asset(name: isInCurrentTimetable ? "search.remove.fill" : "search.add"),
                            text: isInCurrentTimetable ? "제거하기" : "추가하기"
                        ) {
                            if isInCurrentTimetable {
                                await viewModel.removeLecture(lecture)
                            } else {
                                await viewModel.addLecture(lecture)
                            }
                        }
                    }
                    /// This `sheet` modifier should be called on `HStack` to prevent animation glitch when `dismiss`ed.
                    .sheet(isPresented: $isReviewWebViewPresented) {
                        ReviewScene(
                            viewModel: .init(container: viewModel.container),
                            isMainWebView: false,
                            detailId: reviewDetailId
                        )
                        .id(reviewDetailId)
                    }
                    .sheet(isPresented: $isDetailPagePresented) {
                        NavigationView {
                            LectureDetailScene(
                                viewModel: .init(container: viewModel.container),
                                lecture: lecture,
                                displayMode: .preview(shouldHideDismissButton: false)
                            )
                        }
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
        }
        .onChange(of: isSelected) { isSelected in
            if isSelected {
                resignFirstResponder()
            }
        }
        .alert(viewModel.errorTitle, isPresented: $viewModel.isLectureOverlapped) {
            Button {
                Task {
                    await viewModel.forciblyAddLecture(lecture)
                }
            } label: {
                Text("확인")
            }
            Button("취소", role: .cancel) {
                viewModel.isLectureOverlapped = false
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("관심강좌", isPresented: $viewModel.isFirstBookmarkAlertPresented) {
            Button("확인", role: .cancel, action: {
                viewModel.isFirstBookmarkAlertPresented = false
            })
        } message: {
            Text("시간표 우측 상단에서 선택한 관심강좌 목록을 확인해보세요")
        }
    }
}

extension ExpandableLectureCell {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var isLectureOverlapped: Bool = false
        @Published var isFirstBookmarkAlertPresented: Bool = false
        var errorTitle: String = ""
        var errorMessage: String = ""

        private var searchState: SearchState {
            appState.search
        }

        private var timetableState: TimetableState {
            appState.timetable
        }

        var selectedTab: TabType {
            get { appState.system.selectedTab }
            set { services.globalUIService.setSelectedTab(newValue) }
        }
    }
}

extension ExpandableLectureCell.ViewModel {
    func addLecture(_ lecture: Lecture) async {
        do {
            try await services.lectureService.addLecture(lecture: lecture)
        } catch {
            if let error = error.asSTError {
                if error.code == .LECTURE_TIME_OVERLAP {
                    isLectureOverlapped = true
                    errorTitle = error.title
                    errorMessage = error.content
                } else {
                    services.globalUIService.presentErrorAlert(error: error)
                }
            }
        }
    }

    func forciblyAddLecture(_ lecture: Lecture) async {
        do {
            try await services.lectureService.addLecture(lecture: lecture, isForced: true)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func removeLecture(_ lecture: Lecture) async {
        guard isInCurrentTimetable(lecture: lecture)
        else { return }
        do {
            try await services.lectureService.deleteLecture(lecture: lecture)
            services.searchService.setSelectedLecture(nil)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func addVacancyLecture(_ lecture: Lecture) async {
        do {
            try await services.vacancyService.addLecture(lecture: lecture)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func removeVacancyLecture(_ lecture: Lecture) async {
        do {
            try await services.vacancyService.deleteLectures(lectures: [lecture])
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func addBookmarkLecture(_ lecture: Lecture) async {
        isFirstBookmarkAlertPresented = appState.timetable.isFirstBookmark ?? false
        do {
            try await services.lectureService.bookmarkLecture(lecture: lecture)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func removeBookmarkLecture(_ lecture: Lecture) async {
        guard isBookmarked(lecture: lecture) else { return }
        do {
            try await services.lectureService.undoBookmarkLecture(lecture: lecture)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func reloadReviewWebView(evLectureId: Int) {
        services.globalUIService.sendDetailWebViewReloadSignal(
            url: WebViewType.reviewDetail(id: evLectureId).url
        )
    }

    private func isBookmarked(lecture: Lecture) -> Bool {
        timetableState.bookmark?.lectures
            .contains(where: { $0.isEquivalent(with: lecture) }) ?? false
    }

    private func isInCurrentTimetable(lecture: Lecture) -> Bool {
        timetableState.current?.lectures
            .contains { $0.isEquivalent(with: lecture) } ?? false
    }

    private func isVacancyNotificationEnabled(lecture: Lecture) -> Bool {
        appState.vacancy.lectures
            .contains { $0.isEquivalent(with: lecture) }
    }
}

extension ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    func objectWillChangeWhen(triggeredBy publishers: Any...) -> AnyCancellable {
        let typeErasedPublishers = publishers.compactMap {
            let publisher = $0 as? (any Publisher)
            return publisher?.eraseToAnyVoidPublisher()
        }
        return Publishers.MergeMany(typeErasedPublishers)
            .sink { [weak self] _ in self?.objectWillChange.send() }
    }
}

extension Publisher {
    func eraseToAnyVoidPublisher() -> AnyPublisher<Void, Never> {
        return map { _ in () }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
}
