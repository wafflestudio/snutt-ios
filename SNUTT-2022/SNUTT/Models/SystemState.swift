//
//  System.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Foundation

class SystemState: ObservableObject {
    @Published var isErrorAlertPresented = false
    @Published var errorContent: STError? = nil
}
