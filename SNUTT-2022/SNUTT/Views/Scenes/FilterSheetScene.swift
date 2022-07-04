//
//  FilterSheetScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct FilterSheetScene: View {
    @ObservedObject var filterSheetState: FilterSheetStates

    init() {
        filterSheetState = AppState.of.filterSheet
    }

    var body: some View {
        FilterSheet(isOpen: $filterSheetState.isOpen) {
            FilterSheetContent()
        }
    }
}

struct FilterSheetScene_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            Button {
                AppState.of.filterSheet.isOpen.toggle()
            } label: {
                Text("버튼 클릭")
            }
            FilterSheetScene()
        }
    }
}
