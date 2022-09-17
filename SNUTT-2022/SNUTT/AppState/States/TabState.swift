//
//  TabState.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/30.
//

import Combine
import SwiftUI

class TabState: ObservableObject {
    @Published var selected: TabType = .timetable
}
