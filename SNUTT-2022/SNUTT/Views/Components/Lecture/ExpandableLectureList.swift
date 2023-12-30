//
//  ExpandableLectureList.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/12/17.
//

import Combine
import SwiftUI

struct ExpandableLectureList: View {
    @ObservedObject var viewModel: ViewModel

    let lectures: [Lecture]
    @Binding var selectedLecture: Lecture?
    var fetchMoreLectures: (() async -> Void)? = nil

    var body: some View {
        let _ = debugChanges()
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(lectures) { lecture in
                    ExpandableLectureCell(
                        viewModel: .init(container: viewModel.container),
                        lecture: lecture,
                        isSelected: lecture.id == selectedLecture?.id,
                        isBookmarked: viewModel.isBookmarked(lecture: lecture),
                        isInCurrentTimetable: viewModel.isInCurrentTimetable(lecture: lecture),
                        isVacancyNotificationEnabled: viewModel.isVacancyNotificationEnabled(lecture: lecture)
                    )

                    .task {
                        if lecture.id == lectures.last?.id {
                            await fetchMoreLectures?()
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedLecture?.id != lecture.id {
                            selectedLecture = lecture
                        }
                    }
                }
            }
        }
        .scrollDismissesKeyboardInteractively()
    }
}

extension ExpandableLectureList {
    class ViewModel: BaseViewModel, ObservableObject {
        private var timetableState: TimetableState {
            appState.timetable
        }

        private var cancellables: Set<AnyCancellable> = .init()

        override init(container: DIContainer) {
            super.init(container: container)

            objectWillChangeWhen(triggeredBy:
                timetableState.$bookmark,
                timetableState.$current,
                appState.vacancy.$lectures)
                .store(in: &cancellables)
        }

        func isBookmarked(lecture: Lecture) -> Bool {
            timetableState.bookmark?.lectures
                .contains(where: { $0.isEquivalent(with: lecture) }) ?? false
        }

        func isInCurrentTimetable(lecture: Lecture) -> Bool {
            timetableState.current?.lectures
                .contains { $0.isEquivalent(with: lecture) } ?? false
        }

        func isVacancyNotificationEnabled(lecture: Lecture) -> Bool {
            appState.vacancy.lectures
                .contains { $0.isEquivalent(with: lecture) }
        }
    }
}
