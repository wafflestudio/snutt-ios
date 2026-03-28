//
//  NotificationCenterDependency.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesAdditions
import Foundation

extension NotificationCenter {
    public protocol TypedMessage: Sendable {
        static var name: Notification.Name { get }
    }
}

extension NotificationCenter.Dependency {
    public func messages<Message: NotificationCenter.TypedMessage>(of messageType: Message.Type) -> AsyncStream<Message>
    {
        notifications(named: messageType.name)
            .compactMap {
                $0.userInfo?[messageType.name] as? Message
            }
            .eraseToStream()
    }

    public func post<Message: NotificationCenter.TypedMessage>(_ message: Message) {
        let name = type(of: message).name
        self.post(name: name, userInfo: [name: message])
    }
}
