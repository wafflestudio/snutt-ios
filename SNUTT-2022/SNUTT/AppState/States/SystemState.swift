//
//  SystemState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import UIKit
import Combine

class SystemState: ObservableObject {
    @Published var isErrorAlertPresented = false
    @Published var error: STError? = nil
}
