//
//  PopupRepository.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/04.
//

import Alamofire
import Foundation

protocol PopupRepositoryProtocol {
    func getRecentPopupList() async throws -> [PopupDto]
}

class PopupRepository: PopupRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func getRecentPopupList() async throws -> [PopupDto] {
        return try await session
            .request(PopupRouter.getPopupList)
            .serializingDecodable(PopupResponseDto.self)
            .handlingError()
            .content
    }
}
