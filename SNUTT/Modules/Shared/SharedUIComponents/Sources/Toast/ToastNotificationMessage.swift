//
//  ToastNotificationMessage.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import DependenciesUtility
import Foundation

public struct ToastNotificationMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("presentToast")
    public let toast: Toast
}

extension NotificationCenter.TypedMessage where Self == ToastNotificationMessage {
    public static func toast(_ toast: Toast) -> Self {
        ToastNotificationMessage(toast: toast)
    }

    public static func toast(error: any ErrorWrapper) -> Self {
        let error = AnyLocalizedError(underlyingError: error.underlyingError)
        return ToastNotificationMessage(
            toast: .init(
                message: error.errorMessage ?? SharedUIComponentsStrings.errorUnknownMessage
            )
        )
    }
}
