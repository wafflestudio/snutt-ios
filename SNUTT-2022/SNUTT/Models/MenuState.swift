//
//  MenuState.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import SwiftUI

class MenuState: ObservableObject {
    @Published var isOpen = false

    /// The target timetable that the ellipsis sheet is open for.
    @Published var ellipsisTarget: TimetableMetadata? = nil

    @Published var isEllipsisSheetOpen = false
    @Published var isThemeSheetOpen = false

    // MARK: Rename Timetable

    @Published var isRenameSheetOpen = false
    @Published var renameTitle: String = ""

    // MARK: Create Timetable

    @Published var isCreateSheetOpen = false
    @Published var createTitle: String = ""
    @Published var createQuarter: Quarter? = nil
}
