//
//  TimetableUIProvider.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

public struct TimetableUIProvider: TimetableUIProvidable {
    public nonisolated init() {}
    public func lectureDetailRow(type: TimetableInterface.DetailLabelType,
                                 lecture: TimetableInterface.Lecture) -> AnyView
    {
        AnyView(LectureDetailRow(type: type, lecture: lecture))
    }
}
