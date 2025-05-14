//
//  PushRepository.swift
//  SNUTT
//
//  Created by 이채민 on 5/11/25.
//

import Alamofire
import Foundation

protocol PushRepositoryProtocol {
    func getPreference() async throws -> PushDto
    func updatePreference(lectureUpdate: PushPreferenceDto, vacancy: PushPreferenceDto) async throws
}

class PushRepository: PushRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func getPreference() async throws -> PushDto {
        return try await session
            .request(PushRouter.getPreference)
            .serializingDecodable(PushDto.self)
            .handlingError()
    }

    func updatePreference(lectureUpdate: PushPreferenceDto, vacancy: PushPreferenceDto) async throws {
        let preferences = [lectureUpdate, vacancy]
        let _ = try await session
            .request(PushRouter.updatePreference(preferences: preferences))
            .serializingString(emptyResponseCodes: [200])
            .handlingError()
    }
}
