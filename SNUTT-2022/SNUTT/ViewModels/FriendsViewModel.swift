//
//  FriendsViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/15.
//

import Foundation
import Combine
import ReactNativeKit
import KakaoSDKShare
import KakaoSDKCommon
import KakaoSDKTemplate
import UIKit

class FriendsViewModel: BaseViewModel, ObservableObject {
    private let eventEmitter: EventEmitter<RNEvent> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    @Published
    private(set) var friendRequestError: FriendRequestError?

    var isErrorAlertPresented: Bool {
        get { friendRequestError != nil }
        set {
            if !newValue {
                friendRequestError = nil
            }
        }
    }

    override init(container: DIContainer) {
        super.init(container: container)
        appState.friend.$pendingFriendRequestToken
            .compactMap { $0 }
            .sink { token in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    appState.friend.pendingFriendRequestToken = nil
                    await eventEmitter.emitEvent(.addFriendKakao, payload: ["requestToken": token])
                }
            }
            .store(in: &cancellables)

    }

    var accessToken: String? {
        appState.user.accessToken
    }

    func fetchReactNativeBundleUrl() async -> URL? {
        do {
            return try await services.friendsService.fetchReactNativeBundleUrl()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
        return nil
    }
}

// MARK: Kakao Friend Request

extension FriendsViewModel {
    enum FriendRequestError: LocalizedError {
        case shareUnavailable
        case preparationFailed
        case unknownError

        var errorDescription: String? {
            switch self {
            case .shareUnavailable:
                "카카오톡 초대 기능을 사용할 수 없습니다."
            case .preparationFailed, .unknownError:
                "알 수 없는 오류가 발생했습니다."
            }
        }

        var failureReason: String? {
            nil
        }

        var helpAnchor: String? { nil }

        var recoverySuggestion: String? {
            switch self {
            case .shareUnavailable:
                "카카오톡이 설치되어 있는지 확인해보세요."
            case .preparationFailed, .unknownError:
                "개발자 괴롭히기를 통해 문의해주세요."
            }
        }
    }

    func bindEventEmitter() async {
        await eventEmitter.jsEventPublisher
            .sink { event in
                switch event.name {
                case RNEvent.addFriendKakao.rawValue:
                    guard let requestToken = event.payload?["requestToken"] as? String else { return }
                    Task { @MainActor in
                        do {
                            try await self.sendKakaoMessage(with: requestToken)
                        } catch let error as FriendRequestError {
                            self.friendRequestError = error
                        }
                    }
                default:
                    return
                }
            }
            .store(in: &cancellables)
    }

    func sendKakaoMessage(with requestToken: String) async throws {
        guard ShareApi.isKakaoTalkSharingAvailable() else { throw FriendRequestError.shareUnavailable }
        let params = ["type": RNEvent.addFriendKakao.rawValue, "requestToken": requestToken]
        let link = Link(androidExecutionParams: params, iosExecutionParams: params)
        let button = Button(title: "수락하기", link: link)
        let feedTemplate = FeedTemplate(content: .init(title: "SNUTT : 서울대학교 시간표 앱",imageUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource122/v4/f0/c6/58/f0c6581d-dd41-3bad-9d9a-516561d35af1/0d1dfc21-5d2e-4dcf-8cff-c6eb25fe7284_2_2.png/460x0w.webp"), description: "스누티티 친구 초대가 도착했어요", link: link), buttons: [button])
        let feedTemplateJsonData = try SdkJSONEncoder.custom.encode(feedTemplate)
        guard let templateJsonObject = SdkUtils.toJsonObject(feedTemplateJsonData) else { throw FriendRequestError.preparationFailed }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            ShareApi.shared.shareDefault(templateObject:templateJsonObject) {(sharingResult, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if let sharingResult {
                    UIApplication.shared.open(sharingResult.url,
                                              options: [:], completionHandler: nil)
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: FriendRequestError.unknownError)
                }
            }
        }

    }
}
