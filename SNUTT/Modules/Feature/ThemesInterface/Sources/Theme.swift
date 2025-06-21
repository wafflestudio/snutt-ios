//
//  Theme.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import MemberwiseInit
import SwiftUI
import SwiftUIUtility

@MemberwiseInit(.public)
public struct Theme: Identifiable, Sendable, Codable, Equatable {
    public let id: String
    public let name: String
    public let colors: [LectureColor]

    /// 사용자 생성 커스텀 테마
    public let isCustom: Bool
}

@MemberwiseInit(.public)
public struct LectureColor: Hashable, Sendable, Codable {
    public var fgHex: String
    public var bgHex: String
    public var fg: Color { Color(hex: fgHex) }
    public var bg: Color { Color(hex: bgHex) }

    public static let temporary: Self = .init(fgHex: "#000000", bgHex: "#C4C4C4")
}
