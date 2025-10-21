//
//  TermsOfServiceView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import SharedUIWebKit
import SwiftUI

struct TermsOfServiceView: View {
    @Dependency(\.appMetadata) private var appMetadata
    var body: some View {
        SwiftUIWebView(url: url)
    }

    private var url: URL {
        appMetadata.apiURL.appending(path: "terms_of_service")
    }
}
