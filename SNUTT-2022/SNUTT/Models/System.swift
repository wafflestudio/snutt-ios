//
//  System.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Foundation

struct System {
    enum State {
        case error
        case success
    }
    
    var showActivityIndicator = false
    var state: State = .success
}
