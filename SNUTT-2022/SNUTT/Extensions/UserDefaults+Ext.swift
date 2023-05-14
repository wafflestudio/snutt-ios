//
//  UserDefaults+Ext.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/06.
//

import Foundation

extension UserDefaults {
    
    static var groupName: String {
        #if DEBUG
        "group.com.wafflestudio.snutt.dev"
        #else
        "group.com.wafflestudio.snutt"
        #endif
    }
    
    /// To share data saved in UserDefaults with App Extensions
    static var shared: UserDefaults {
        return UserDefaults(suiteName: groupName)!
    }
    
    #if DEBUG
    static var preview: UserDefaults {
        return UserDefaults(suiteName: "\(groupName).preview")!
    }
    #endif
}
