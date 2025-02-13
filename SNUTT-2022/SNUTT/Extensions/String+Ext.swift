//
//  String+Ext.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/16.
//

import Foundation
import SwiftUI

extension String {
    /// Transform `String` into `AttributedString` supporting markdown
    var markdown: AttributedString {
        try! AttributedString(markdown: self, options: .init(interpretedSyntax: .inlineOnly))
    }
    
    /// Add single lined underline
    /// - NOTE: underline color is fixed to `STColor.gray2`
    func toUnderlinedString(textColor: Color) -> AttributedString {
        AttributedString(self, attributes: AttributeContainer([
            .underlineStyle: 1,
            .underlineColor: UIColor(STColor.gray2),
            .foregroundColor: UIColor(textColor)
        ]))
    }
}
