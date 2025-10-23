//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

enum AnalyticsScreen: AnalyticsLogEvent {
    case themeHome
    case themeMarket
    case themeBasicDetail
    case themeCustomNew
    case themeCustomEdit
    case themePreview
    case themeDownloaded

    var eventName: String {
        switch self {
        case .themeHome:
            "theme_home"
        case .themeMarket:
            "theme_market"
        case .themeBasicDetail:
            "theme_basic_detail"
        case .themeCustomNew:
            "theme_custom_new"
        case .themeCustomEdit:
            "theme_custom_edit"
        case .themePreview:
            "theme_preview"
        case .themeDownloaded:
            "theme_downloaded"
        }
    }

    var parameters: [String: String]? { nil }
}
