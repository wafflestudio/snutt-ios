//
//  PushRouter.swift
//  SNUTT
//
//  Created by 이채민 on 5/10/25.
//

import Alamofire
import Foundation

enum PushRouter: Router {
    var baseURL: URL { return URL(string: NetworkConfiguration.serverV1BaseURL + "/push")! }

    case getPreference
    case updatePreference(preferences: [PushPreferenceDto])

    var method: HTTPMethod {
        switch self {
        case .getPreference:
            return .get
        case .updatePreference:
            return .post
        }
    }

    var path: String {
        switch self {
        case .getPreference:
            return "/preferences"
        case .updatePreference:
            return "/preferences"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getPreference:
            return nil
        case let .updatePreference(preferences):
            return ["pushPreferences": preferences.encodeToJSONArray() ?? []]
        }
    }
}

extension Encodable {
    public func asAnyDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let dictionary = jsonObject as? [String: Any]
        else {
            return nil
        }
        return dictionary
    }
}

extension Array where Element: Encodable {
    public func encodeToJSONArray() -> [[String: Any]]? {
        return compactMap { $0.asAnyDictionary() }
    }
}
