//
//  SearchLectureScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct SearchLectureScene: View {
    
    @ObservedObject var filterSheetState: FilterSheetStates

    init() {
        filterSheetState = AppState.of.filterSheet
    }
    
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Text("This is the main timetable view.")
            Color.black.opacity(0.3)
            VStack {
                SearchBar(text: $searchText, isFilterOpen: $filterSheetState.isOpen)
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct SearchLectureScene_Previews: PreviewProvider {
    static var previews: some View {
        SearchLectureScene()
    }
}
