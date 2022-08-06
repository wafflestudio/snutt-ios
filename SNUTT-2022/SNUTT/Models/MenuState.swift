//
//  MenuState.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import SwiftUI

class MenuState: ObservableObject {
    @Published var isOpen = false

    @Published var isEllipsisOpen = false
    @Published var ellipsisTarget: TimetableMetadata? = nil
    @Published var isThemePaletteOpen = false

    @Published var isTitleTextFieldOpen = false
    @Published var titleText: String = ""
}
