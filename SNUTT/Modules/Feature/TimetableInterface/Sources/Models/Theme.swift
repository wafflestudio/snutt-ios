//
//  Theme.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SwiftUIUtility
import MemberwiseInit
import Foundation

@MemberwiseInit(.public)
public struct Theme: Identifiable, Sendable, Codable {
    public let id: String
    public let name: String
    public let colors: [LectureColor]

    /// 사용자 생성 커스텀 테마
    public let isCustom: Bool
}


@MemberwiseInit(.public)
public struct LectureColor: Hashable, Sendable, Codable {
    public let fgHex: String
    public let bgHex: String
    public var fg: Color { Color(hex: fgHex) }
    public var bg: Color { Color(hex: bgHex) }

    public static let temporary: Self = .init(fgHex: "#000000", bgHex: "#121213")
}
