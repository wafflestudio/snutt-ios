//
//  UserRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Alamofire
import Foundation

protocol UserRepositoryProtocol {
    var userLocalId: String? { get }
    var token: String? { get }
    var fbName: String? { get }
    func cache(token: String)
    func cache(localId: String)
    func cache(fbName: String)
}

class UserRepository: UserRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }
    
    var userLocalId: String? {
        local.userLocalId
    }
    
    var token: String? {
        local.token
    }

    var fbName: String? {
        local.userFBName
    }
    
    func cache(token: String) {
        local.token = token
    }
    
    func cache(localId: String) {
        local.userLocalId = localId
    }
    
    func cache(fbName: String) {
        local.userFBName = fbName
    }
}
