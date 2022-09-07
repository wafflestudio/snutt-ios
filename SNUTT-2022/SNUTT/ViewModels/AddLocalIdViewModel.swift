//
//  AddLocalIdViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/12.
//

import Foundation
import SwiftUI

class AddLocalIdViewModel: BaseViewModel {
    func addLocalId(id: String, password: String, passwordCheck: String) {
        if Validation.check(id: id, password: password, check: passwordCheck) {
            // TODO: Alert 연결
        }
    }
    
    private var userService: UserServiceProtocol {
        services.userService
    }
}
