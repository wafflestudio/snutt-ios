//
//  UserDefaults+ext.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/06.
//

import Foundation

extension UserDefaults {
    /// To share data saved in UserDefaults with App Extensions
    static var shared: UserDefaults {
        return UserDefaults(suiteName: "group.com.wafflestudio.snutt3")!
    }
    
    #if DEBUG
    static var preview: UserDefaults {
        return UserDefaults(suiteName: "group.com.wafflestudio.snutt3.preview")!
    }
    #endif
}
