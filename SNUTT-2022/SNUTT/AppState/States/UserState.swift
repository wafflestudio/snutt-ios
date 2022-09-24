//
//  UserState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

class UserState: ObservableObject {
    
    // TODO: deprecated. this is not a state
    let apiKey: String? = Bundle.main.infoDictionary?["API_KEY"] as? String
    
    @Published var accessToken: String?
    @Published var current: User?
}
