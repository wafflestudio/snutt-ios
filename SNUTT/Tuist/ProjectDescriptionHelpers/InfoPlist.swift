import Foundation
import ProjectDescription

public struct InfoPlist {
    static func infoPlistForApp() -> [String: Plist.Value] {
        [
            "CFBundleShortVersionString": marketingVersion,
            "CFBundleVersion": buildNumber,
            "UILaunchStoryboardName": "LaunchScreen",
            "API_SERVER_URL": "https://$(API_SERVER_URL)",
            "API_KEY": "$(API_KEY)",
            "SNUEV_WEB_URL": "https://$(SNUEV_WEB_URL)",
            "THEME_WEB_URL": "https://$(THEME_WEB_URL)",
            "KAKAO_APP_KEY": "$(KAKAO_APP_KEY)",
            "GIDClientID": "$(GOOGLE_CLIENT_ID)",
            "FacebookAppID": "$(FACEBOOK_APP_ID)",
            "FacebookDisplayName": "$(FACEBOOK_DISPLAY_NAME)",
            "FacebookClientToken": "$(FACEBOOK_CLIENT_TOKEN)",
            "LSApplicationQueriesSchemes": [
                "kakaokompassauth",
                "kakaolink",
                "kakao$(KAKAO_APP_KEY)",
                "fbauth2",
                "fb-messenger-share-api",
                "com.googleusercontent.apps.$(GOOGLE_CLIENT_ID)",
            ],
            "CFBundleURLTypes": [
                .dictionary([
                    "CFBundleURLSchemes": .array([.string("$(URL_SCHEME)")]),
                    "CFBundleURLName": .string("$(PRODUCT_BUNDLE_IDENTIFIER)"),
                ]),
                .dictionary([
                    "CFBundleURLSchemes": .array([.string("$(GOOGLE_REVERSED_CLIENT_ID)")]),
                    "CFBundleURLName": .string("google"),
                ]),
                .dictionary([
                    "CFBundleURLSchemes": .array([.string("kakao$(KAKAO_APP_KEY)")]),
                    "CFBundleURLName": .string("kakao"),
                ]),
                .dictionary([
                    "CFBundleURLSchemes": .array([.string("fb$(FACEBOOK_APP_ID)")]),
                    "CFBundleURLName": .string("facebook"),
                ]),
            ],
        ]
    }
}
