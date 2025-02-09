//
//  UserDefaultsRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/18.
//

import Foundation

protocol UserDefaultsRepositoryProtocol {
    func set<T: Codable>(_ type: T.Type, key: STDefaultsKey, value: T?)
    func get<T: Codable>(_ type: T.Type, key: STDefaultsKey) -> T?
    func get<T: Codable>(_ type: T.Type, key: STDefaultsKey, defaultValue: T) -> T
}

enum STDefaultsKey: String {
    case accessToken
    case apiKey
    case userId
    case userDto
    case fcmToken
    case preferredColorScheme
    case recentDepartmentTags

    case currentTimetable
    case timetableConfig
    case currentTheme

    case expandLectureMapView

    case popupList

    case bookmark
    case isFirstBookmark
}

class UserDefaultsRepository: UserDefaultsRepositoryProtocol {
    private let storage: UserDefaults

    init(storage: UserDefaults) {
        self.storage = storage
    }

    func set<T: Codable>(_: T.Type, key: STDefaultsKey, value: T?) {
        let encodedData = try? JSONEncoder().encode(value)
        storage.set(encodedData, forKey: key.rawValue)
    }

    func get<T: Codable>(_: T.Type, key: STDefaultsKey) -> T? {
        guard let existing = storage.object(forKey: key.rawValue) as? Data else {
            return nil
        }
        let decodedData = try? JSONDecoder().decode(T.self, from: existing)
        return decodedData
    }

    func get<T: Codable>(_: T.Type, key: STDefaultsKey, defaultValue: T) -> T {
        guard let existing = storage.object(forKey: key.rawValue) as? Data else {
            return defaultValue
        }
        let decodedData = try? JSONDecoder().decode(T.self, from: existing)
        return decodedData ?? defaultValue
    }
}
