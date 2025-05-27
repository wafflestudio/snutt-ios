//
//  PushState.swift
//  SNUTT
//
//  Created by 이채민 on 5/11/25.
//

import Combine
import Foundation

struct PushNotificationOptions: OptionSet, Codable {
    let rawValue: Int8
    init(rawValue: Int8) { self.rawValue = rawValue }

    static let lectureUpdate = PushNotificationOptions(rawValue: 1 << 0)
    static let vacancy = PushNotificationOptions(rawValue: 1 << 1)
    static let `default`: PushNotificationOptions = [.lectureUpdate, .vacancy]
}

class PushState: ObservableObject {
    @Published var options: PushNotificationOptions = .default

    var isLectureUpdatePushOn: Bool {
        get { options.contains(.lectureUpdate) }
        set {
            if newValue { options.insert(.lectureUpdate) }
            else { options.remove(.lectureUpdate) }
        }
    }

    var isVacancyPushOn: Bool {
        get { options.contains(.vacancy) }
        set {
            if newValue { options.insert(.vacancy) }
            else { options.remove(.vacancy) }
        }
    }
}
