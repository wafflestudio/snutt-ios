//
//  ColorScheme.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/12/14.
//

import SwiftUI


extension ColorScheme {
    var description: String {
        switch self {
        case .dark:
            return "dark"
        case .light:
            return "light"
        @unknown default:
            return "light"
        }
    }
    
    static func from(description: String?) -> Self? {
        if description == "light" {
            return .light
        }
        
        if description == "dark" {
            return .dark
        }
        
        return nil
    }
}

