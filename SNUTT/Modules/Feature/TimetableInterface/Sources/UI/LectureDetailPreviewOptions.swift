//
//  LectureDetailPreviewOptions.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

public struct LectureDetailPreviewOptions: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// 왼쪽 dismiss 버튼 표시
    public static let showDismissButton = LectureDetailPreviewOptions(rawValue: 1 << 0)

    /// 오른쪽 툴바 액션 버튼들 (공석알림, 북마크) 표시
    public static let showToolbarActions = LectureDetailPreviewOptions(rawValue: 1 << 1)

    /// 모든 버튼 표시
    public static let all: LectureDetailPreviewOptions = [.showDismissButton, .showToolbarActions]
}
