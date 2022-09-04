//
//  System.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import UIKit

class SystemState: ObservableObject {
    @Published var isErrorAlertPresented = false
    @Published var errorContent: STError? = nil

    /// Required to synchronize between two navigation bar heights: `TimetableScene` and `SearchLectureScene`.
    @Published var navigationBarHeight: CGFloat = 80
}
