//
//  EtcRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/07.
//

import Alamofire
import Foundation

protocol EtcRepositoryProtocol {
    func sendFeedback(email: String, message: String) async throws
}

class EtcRepository: EtcRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func sendFeedback(email: String, message: String) async throws {
        let _ = try await session.request(EtcRouter.feedback(email: email, message: message))
            .serializingString()
            .handlingError()
    }
}
