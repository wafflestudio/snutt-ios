//
//  FilterSheetSetting.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import SwiftUI

// TODO: rename this
class FilterSheetSetting: ObservableObject {
    @Published var isOpen = false
    @Published var searchTagList: SearchTagList?
    @Published var selectedTagList: [SearchTag] = []
    @Published var searchResult: [Lecture] = []
    @Published var searchText = ""
    
    let perPage: Int = 20
    var pageNum: Int = 0
}
