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
    case makeBasicThemeDefault(themeType: Int)
    case undoBasicThemeDefault(themeType: Int)
    case makeCustomThemeDefault(themeId: String)
    case undoCustomThemeDefault(themeId: String)

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
        case .makeBasicThemeDefault:
            return .post
        case .undoBasicThemeDefault:
            return .delete
        case .makeCustomThemeDefault:
            return .post
        case .undoCustomThemeDefault:
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
            return "\(themeId)"
        case let .makeBasicThemeDefault(themeType):
            return "/basic/\(themeType)/default"
        case let .undoBasicThemeDefault(themeType):
            return "/basic/\(themeType)/default"
        case let .makeCustomThemeDefault(themeId):
            return "/\(themeId)/default"
        case let .undoCustomThemeDefault(themeId):
            return "/\(themeId)/default"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getThemeList:
            return nil
        case let .addTheme(name, colors):
            return ["name": name, "colors": colors]
        case let .updateTheme(_, name, colors):
            return ["name": name, "colors": colors]
        case .copyTheme:
            return nil
        case .deleteTheme:
            return nil
        case .makeBasicThemeDefault:
            return nil
        case .undoBasicThemeDefault:
            return nil
        case .makeCustomThemeDefault:
            return nil
        case .undoCustomThemeDefault:
            return nil
        }
    }
}
