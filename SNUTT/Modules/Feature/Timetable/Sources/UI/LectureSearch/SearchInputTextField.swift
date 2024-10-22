//
//  SearchInputTextField.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct SearchInputTextField: View {
    @Binding var query: String

    var body: some View {
        TextField("검색어를 입력하세요", text: $query)
            .padding(6)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
