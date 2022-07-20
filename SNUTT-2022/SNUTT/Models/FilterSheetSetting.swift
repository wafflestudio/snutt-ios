//
//  FilterSheetSetting.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import SwiftUI

class FilterSheetSetting: ObservableObject {
    @Published var isOpen = false
    @Published var searchTagList: SearchTagList?
    @Published var selectedTagList: [SearchTag] = []
}
