//
//  PopupState.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/07.
//

import Foundation

class PopupState: ObservableObject {
    @Published var currentList: [Popup] = []
    @Published var currentIndex: Int = 0
    @Published var shouldShowPopup: Bool = false
}