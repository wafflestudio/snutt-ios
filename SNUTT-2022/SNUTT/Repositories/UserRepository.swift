//
//  UserRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Foundation
import Alamofire

protocol UserRepositoryProtocol {
}

class UserRepository: UserRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }
}
