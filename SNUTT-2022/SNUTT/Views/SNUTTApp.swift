//
//  SNUTTApp.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import KakaoMapsSDK
import KakaoSDKAuth
import KakaoSDKCommon
import SwiftUI

@main
struct SNUTTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let appEnvironment: AppEnvironment
    let deepLinkHandler: DeepLinkHandler

    init() {
        appEnvironment = AppEnvironment.bootstrap()
        deepLinkHandler = DeepLinkHandler(dependency: .init(
            appState: appEnvironment.container.appState,
            timetableService: appEnvironment.container.services.timetableService,
            lectureService: appEnvironment.container.services.lectureService
        )
        )
        let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as! String
        KakaoSDK.initSDK(appKey: kakaoAppKey)
        SDKInitializer.InitSDK(appKey: kakaoAppKey)
    }

    var body: some Scene {
        WindowGroup {
            SNUTTView(viewModel: .init(container: appEnvironment.container))
                .environment(\.dependencyContainer, appEnvironment.container)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                    Task {
                        do {
                            try await deepLinkHandler.open(url: url)
                        } catch {
                            appEnvironment.container.services.globalUIService.presentErrorAlert(error: error)
                        }
                    }
                }
        }
    }
}
