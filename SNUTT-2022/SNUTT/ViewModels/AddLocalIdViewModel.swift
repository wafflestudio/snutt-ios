//
//  AddLocalIdViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/12.
//

import Foundation
import SwiftUI

class AddLocalIdViewModel: BaseViewModel {
    private var userService: UserServiceProtocol {
        services.userService
    }

    private var validationService: ValidationServiceProtocol {
        services.validationService
    }

    func addLocalId(id: String, password: String, passwordCheck: String) {
        if validationService.isValid(id: id, password: password, check: passwordCheck) {
            // TODO: Alert 연결
        }
    }
}
