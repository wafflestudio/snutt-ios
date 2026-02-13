//
//  DeveloperInfoView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import SharedUIWebKit
import SwiftUI

struct DeveloperInfoView: View {
    @Dependency(\.appMetadata) private var appMetadata

    var body: some View {
        SwiftUIWebView(url: url)
    }

    private var url: URL {
        appMetadata.apiURL.appending(path: "member")
    }
}
