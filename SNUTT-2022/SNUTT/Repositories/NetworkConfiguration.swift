//
//  NetworkConfiguration.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/24.
//

import Foundation

struct NetworkConfiguration {
    static let serverBaseURL: String = Bundle.main.infoDictionary?["API_SERVER_URL"] as! String
    static let snuevBaseURL: String = Bundle.main.infoDictionary?["SNUEV_WEB_URL"] as! String
}