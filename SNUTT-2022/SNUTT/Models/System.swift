//
//  System.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import Foundation

typealias ConnectionState = System.State

class System: ObservableObject {
    enum State {
        case error
        case success
    }

    @Published var shouldReloadWebView: Bool = false
    @Published var connectionState: State = .success

    var showActivityIndicator = false
    var state: State = .success
}
