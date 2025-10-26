//
//  KakaoSDKShareService.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate
import UIKit

struct KakaoSDKShareService: KakaoShareService {
    func isKakaoTalkSharingAvailable() -> Bool {
        ShareApi.isKakaoTalkSharingAvailable()
    }

    func shareFriendRequest(requestToken: String) async throws {
        guard ShareApi.isKakaoTalkSharingAvailable() else {
            throw KakaoShareError.shareUnavailable
        }

        let params = ["type": "add-friend-kakao", "requestToken": requestToken]
        let link = Link(androidExecutionParams: params, iosExecutionParams: params)
        let button = Button(title: "수락하기", link: link)
        let content = Content(
            title: "SNUTT : 서울대학교 시간표 앱",
            imageUrl: URL(
                string:
                    "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource122/v4/f0/c6/58/f0c6581d-dd41-3bad-9d9a-516561d35af1/0d1dfc21-5d2e-4dcf-8cff-c6eb25fe7284_2_2.png/460x0w.webp"
            ),
            description: "스누티티 친구 초대가 도착했어요",
            link: link
        )
        let feedTemplate = FeedTemplate(content: content, buttons: [button])
        let feedTemplateJsonData = try SdkJSONEncoder.custom.encode(feedTemplate)
        guard let templateJsonObject = SdkUtils.toJsonObject(feedTemplateJsonData) else {
            throw KakaoShareError.preparationFailed
        }
        return try await withCheckedThrowingContinuation { continuation in
            ShareApi.shared.shareDefault(templateObject: templateJsonObject) { sharingResult, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let sharingResult else {
                    continuation.resume(throwing: KakaoShareError.unknownError)
                    return
                }
                let url = sharingResult.url
                Task { @MainActor in
                    UIApplication.shared.open(url, options: [:]) { success in
                        if success {
                            continuation.resume()
                        } else {
                            continuation.resume(throwing: KakaoShareError.unknownError)
                        }
                    }
                }
            }
        }
    }
}
