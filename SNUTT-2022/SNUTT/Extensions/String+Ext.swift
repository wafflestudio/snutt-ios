//
//  String+Ext.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/16.
//

import Foundation

extension String {
    /// Transform String into AttributedString supporting markdown
    var markdown: AttributedString {
        try! AttributedString(markdown: self, options: .init(interpretedSyntax: .inlineOnly))
    }
}
