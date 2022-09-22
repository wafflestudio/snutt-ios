//
//  WebViewState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import Foundation

class WebViewState: ObservableObject {
    enum Connection {
        case error
        case success
    }

    @Published var connection: Connection = .success
}
