//
//  ExpandableLectureListViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Combine
import CoreGraphics
import Observation
import TimetableInterface

@MainActor
protocol ExpandableLectureListViewModel: Sendable, AnyObject {
    var renderingOptions: ExpandableLectureListRenderingOptions { get }

    var scrollPosition: Lecture.ID? { get set }
    var lectures: [Lecture] { get }
    var selectedLecture: Lecture? { get }
    func selectLecture(_: Lecture)
    func isSelected(lecture: Lecture) -> Bool
    func fetchMoreLectures() async throws
    func toggleAction(lecture: Lecture, type: ActionButtonType, overrideOnConflict: Bool) async throws
    func isToggled(lecture: Lecture, type: ActionButtonType) -> Bool
}

enum ActionButtonType: String, CaseIterable, Identifiable {
    var id: String {
        rawValue
    }

    case detail
    case review
    case bookmark
    case vacancy
    case add
}

extension ExpandableLectureListViewModel {
    var renderingOptions: ExpandableLectureListRenderingOptions {
        []
    }
}

struct ExpandableLectureListRenderingOptions: OptionSet {
    let rawValue: Int

    static let showsDivider = Self(rawValue: 1 << 0)
    static let scaleOnPress = Self(rawValue: 1 << 1)
}
