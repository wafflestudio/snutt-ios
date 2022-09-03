//
//  SearchState.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import SwiftUI

class SearchState: ObservableObject {
    @Published var isFilterOpen = false
    @Published var searchTagList: SearchTagList?
    @Published var selectedTagList: [SearchTag] = []
    @Published var searchResult: [Lecture]?
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var selectedLecture: Lecture?

    let perPage: Int = 20
    var pageNum: Int = 0
}
