//
//  AppReviewStoreURLHandler.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import UIKit

struct AppReviewStoreURLHandlerLive: AppReviewStoreURLHandler {
    private let reviewURL = URL(
        string: "itms-apps://itunes.apple.com/app/id1215668309?action=write-review"
    )
    private let webReviewURL = URL(
        string: "https://apps.apple.com/app/id1215668309?action=write-review"
    )

    func openReviewPage() {
        Task { @MainActor in
            if let url = reviewURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }

            guard let webURL = webReviewURL else { return }
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
}
