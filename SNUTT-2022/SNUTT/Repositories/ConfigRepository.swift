//
//  ConfigRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/08/05.
//

import Alamofire
import Foundation

protocol ConfigRepositoryProtocol {
    func fetchConfigs() async throws -> ConfigsDto
}

class ConfigRepository: ConfigRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchConfigs() async throws -> ConfigsDto {
        return try await session
            .request(ConfigRouter.getConfigs)
            .serializingDecodable(ConfigsDto.self)
            .handlingError()
    }
}
