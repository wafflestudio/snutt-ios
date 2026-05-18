//
//  RegisterTermsOfServiceView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import SharedAppMetadata
import SharedUIWebKit
import SwiftUI

struct RegisterTermsOfServiceView: View {
    @Dependency(\.appMetadata) private var appMetadata
    var body: some View {
        SwiftUIWebView(url: url)
            .ignoresSafeArea()
    }

    private var url: URL {
        appMetadata.apiURL.appending(path: "terms_of_service")
    }
}
