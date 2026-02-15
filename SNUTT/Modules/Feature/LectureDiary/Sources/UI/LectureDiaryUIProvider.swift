//
//  LectureDiaryUIProvider.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import LectureDiaryInterface
import SwiftUI

public struct LectureDiaryUIProvider: LectureDiaryUIProvidable {
    public nonisolated init() {}
    public func makeLectureDiaryListView() -> AnyView {
        AnyView(LectureDiaryListView())
    }
}
