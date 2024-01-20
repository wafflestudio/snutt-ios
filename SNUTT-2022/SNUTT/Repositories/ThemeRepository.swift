//
//  ThemeRepository.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Alamofire
import Foundation

protocol ThemeRepositoryProtocol {
    func getThemeList() async throws -> [ThemeDto]
    func addTheme(name: String, colors: [ThemeColorDto]) async throws -> ThemeDto
    func updateTheme(themeId: String, name: String, colors: [ThemeColorDto]) async throws -> ThemeDto
    func copyTheme(themeId: String) async throws -> ThemeDto
    func deleteTheme(themeId: String) async throws
    func makeBasicThemeDefault(themeType: Int) async throws -> ThemeDto
    func undoBasicThemeDefault(themeType: Int) async throws -> ThemeDto
    func makeCustomThemeDefault(themeId: String) async throws -> ThemeDto
    func undoCustomThemeDefault(themeId: String) async throws -> ThemeDto
}

class ThemeRepository: ThemeRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func getThemeList() async throws -> [ThemeDto] {
        return try await session
            .request(ThemeRouter.getThemeList)
            .serializingDecodable([ThemeDto].self)
            .handlingError()
    }

    func addTheme(name: String, colors: [ThemeColorDto]) async throws -> ThemeDto {
        return try await session
            .request(ThemeRouter.addTheme(name: name, colors: colors))
            .serializingDecodable(ThemeDto.self)
            .handlingError()
    }

    func updateTheme(themeId: String, name: String, colors: [ThemeColorDto]) async throws -> ThemeDto {
        return try await session
            .request(ThemeRouter.updateTheme(themeId: themeId, name: name, colors: colors))
            .serializingDecodable(ThemeDto.self)
            .handlingError()
    }
    
    func copyTheme(themeId: String) async throws -> ThemeDto {
        return try await session
            .request(ThemeRouter.copyTheme(themeId: themeId))
            .serializingDecodable(ThemeDto.self)
            .handlingError()
    }

    func deleteTheme(themeId: String) async throws {
        let _ = try await session
            .request(ThemeRouter.deleteTheme(themeId: themeId))
            .serializingString(emptyResponseCodes: [200])
            .handlingError()
    }

    func makeBasicThemeDefault(themeType: Int) async throws -> ThemeDto {
        return try await session
            .request(ThemeRouter.makeBasicThemeDefault(themeType: themeType))
            .serializingDecodable(ThemeDto.self)
            .handlingError()
    }
    
    func undoBasicThemeDefault(themeType: Int) async throws -> ThemeDto {
        return try await session
            .request(ThemeRouter.undoBasicThemeDefault(themeType: themeType))
            .serializingDecodable(ThemeDto.self)
            .handlingError()
    }

    func makeCustomThemeDefault(themeId: String) async throws -> ThemeDto {
        return try await session
            .request(ThemeRouter.makeCustomThemeDefault(themeId: themeId))
            .serializingDecodable(ThemeDto.self)
            .handlingError()
    }

    func undoCustomThemeDefault(themeId: String) async throws -> ThemeDto {
        return try await session
            .request(ThemeRouter.undoCustomThemeDefault(themeId: themeId))
            .serializingDecodable(ThemeDto.self)
            .handlingError()
    }
}
