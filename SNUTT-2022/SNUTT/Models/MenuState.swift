//
//  MenuState.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import SwiftUI

// TODO: maybe change variable name to `GlobalUIState` in order to match `GlobalUIService`
class MenuState: ObservableObject {
    @Published var isOpen = false

    /// The target timetable that the ellipsis sheet is open for. There's no need to be `@Published` because no view updates on the change this property.
    var ellipsisTarget: TimetableMetadata?

    @Published var isEllipsisSheetOpen = false
    @Published var isThemeSheetOpen = false

    // MARK: Rename Timetable

    @Published var isRenameSheetOpen = false
    @Published var renameTitle: String = ""

    // MARK: Create Timetable

    @Published var isCreateSheetOpen = false
    @Published var createTitle: String = ""
    @Published var createQuarter: Quarter? = nil

    // MARK: Change Lecture Time

    @Published var isLectureTimeSheetOpen = false
    @Published var timePlaceToModify: TimePlace? = nil

    /// Action to perform when `LectureTimeSheet` returns an object conforming to `TimePlace`.
    var lectureTimeSheetAction: ((TimePlace) -> Void)?
}
