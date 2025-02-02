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
protocol ExpandableLectureListViewModel: Sendable {
    var renderingOptions: ExpandableLectureListRenderingOptions { get }

    var lectures: [any Lecture] { get }
    var selectedLecture: (any Lecture)? { get }
    func selectLecture(_: any Lecture)
    func isSelected(lecture: any Lecture) -> Bool
    func fetchMoreLectures() async throws
    func toggleAction(lecture: any Lecture, type: ActionButtonType) async throws
    func isToggled(lecture: any Lecture, type: ActionButtonType) -> Bool
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
}
