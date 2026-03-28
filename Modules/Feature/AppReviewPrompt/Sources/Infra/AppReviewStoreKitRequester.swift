//
//  AppReviewStoreKitRequester.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import StoreKit
import UIKit

struct AppReviewStoreKitRequester: AppReviewRequester {
    func requestReview() {
        Task { @MainActor in
            guard
                let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            else { return }

            if #available(iOS 18, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}
