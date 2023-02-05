//
//  SystemState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import SwiftUI
import UIKit

class SystemState: ObservableObject {
    @Published var isErrorAlertPresented = false
    @Published var error: STError? = nil

    /// The property stores the color scheme that the user has set as their preference.
    /// If `nil`, the system appearance will be used.
    @Published var preferredColorScheme: ColorScheme? = nil

    @Published var selectedTab: TabType = .timetable
}
