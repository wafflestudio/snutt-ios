//
//  UIDevice+Ext.swift
//  SNUTT
//
//  Created by 최유림 on 2023/06/27.
//

import UIKit

extension UIDevice {
    /// Returns the name of device model (ex: iPhone10,2 or iPad3,2)
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let data = Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN))
        let identifier = String(bytes: data, encoding: .ascii)!
        return identifier.trimmingCharacters(in: .controlCharacters)
    }
}
