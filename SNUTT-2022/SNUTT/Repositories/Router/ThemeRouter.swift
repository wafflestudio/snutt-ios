//
//  ThemeRouter.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Alamofire
import Foundation

enum ThemeRouter: Router {
    var baseURL: URL { return URL(string: NetworkConfiguration.serverV1BaseURL + "/themes")! }

    case getThemeList
    case addTheme(name: String, colors: [ThemeColorDto])
    case updateTheme(themeId: String, name: String, colors: [ThemeColorDto])
    case copyTheme(themeId: String)
    case deleteTheme(themeId: String)

    var method: HTTPMethod {
        switch self {
        case .getThemeList:
            return .get
        case .addTheme:
            return .post
        case .updateTheme:
            return .patch
        case .copyTheme:
            return .post
        case .deleteTheme:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .getThemeList:
            return ""
        case .addTheme:
            return ""
        case let .updateTheme(themeId, _, _):
            return "/\(themeId)"
        case let .copyTheme(themeId):
            return "/\(themeId)/copy"
        case let .deleteTheme(themeId):
            return "/\(themeId)"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getThemeList:
            return nil
        case let .addTheme(name, colors):
            let dict = colors.encodeColors()
            return ["name": name, "colors": dict]
        case let .updateTheme(_, name, colors):
            let dict = colors.encodeColors()
            return ["name": name, "colors": dict]
        case .copyTheme:
            return nil
        case .deleteTheme:
            return nil
        }
    }
}

public extension Encodable {
    func encodeColors() -> [[String: String]]? {
        guard let data = asJSONData() else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]]
    }
}
