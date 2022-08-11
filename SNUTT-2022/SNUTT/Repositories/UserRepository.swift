//
//  UserRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Alamofire
import Foundation

protocol UserRepositoryProtocol {}

class UserRepository: UserRepositoryProtocol, LocalCachable {
    private let session: Session

    var local = SNUTTDefaultsContainer()

    init(session: Session) {
        self.session = session
    }
}
