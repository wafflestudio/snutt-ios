//
//  BookmarkListViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Observation
import TimetableInterface

@MainActor
final class BookmarkListViewModel: ExpandableLectureListViewModel {
    let searchViewModel: LectureSearchViewModel
    var scrollPosition: Lecture.ID? {
        get { searchViewModel.scrollPositions[.bookmark] }
        set { searchViewModel.scrollPositions[.bookmark] = newValue }
    }

    init(searchViewModel: LectureSearchViewModel) {
        self.searchViewModel = searchViewModel
    }

    func selectLecture(_ lecture: Lecture) {
        searchViewModel.selectLecture(lecture)
    }

    func isSelected(lecture: Lecture) -> Bool {
        searchViewModel.isSelected(lecture: lecture)
    }

    func fetchMoreLectures() async throws {
        // no-op
    }

    func toggleAction(
        lecture: Lecture,
        type: ActionButtonType,
        overrideOnConflict: Bool
    ) async throws {
        try await searchViewModel.toggleAction(lecture: lecture, type: type, overrideOnConflict: overrideOnConflict)
    }

    func isToggled(lecture: Lecture, type: ActionButtonType) -> Bool {
        searchViewModel.isToggled(lecture: lecture, type: type)
    }

    var lectures: [Lecture] {
        searchViewModel.bookmarkedLectures
    }

    var selectedLecture: Lecture? {
        searchViewModel.selectedLecture
    }
}
