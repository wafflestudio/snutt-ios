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
    public var name: String
    public var colors: [LectureColor]
    public let status: Status

    /// 사용자 생성 커스텀 테마
    public var isCustom: Bool {
        switch status {
        case .customDownloaded, .customPrivate, .customPublished: true
        case .builtIn: false
        }
    }

    public enum Status: Sendable, Codable, Hashable {
        /// 테마 마켓에서 다운로드받은 커스텀 테마
        case customDownloaded
        /// 비공개 커스텀 테마
        case customPrivate
        /// 공개 커스텀 테마
        case customPublished
        /// 내장 테마
        case builtIn
    }
}

@MemberwiseInit(.public)
public struct LectureColor: Hashable, Sendable, Codable {
    public var fgHex: String
    public var bgHex: String
    public var fg: Color { Color(hex: fgHex) }
    public var bg: Color { Color(hex: bgHex) }

    public static let temporary: Self = .init(fgHex: "#000000", bgHex: "#C4C4C4")
    public static let cyan: Self = .init(fgHex: "#FFFFFF", bgHex: "#1BD0C8")
}
