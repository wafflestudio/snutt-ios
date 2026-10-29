//
//  EvaluationsUIProvider.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import EvaluationsInterface
import SwiftUI

public struct EvaluationsUIProvider: EvaluationsUIProvidable {
    public nonisolated init() {}
    public func makeEvaluationsScene(for evLectureID: Int) -> AnyView {
        AnyView(EvaluationsWebScene(evLectureID: evLectureID))
    }

    public func makeEvaluationScene(for evLectureID: EvLectureID) -> AnyView {
        AnyView(EvaluationLectureDetailScene(lectureID: EvaluationLectureID(evLectureID.rawValue)))
    }
}
