//
//  TimetableList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/23.
//

import SwiftUI

struct TimetableList: View {
    var body: some View {
        List {
            ForEach (1..<10) {_ in
                ZStack {
                    NavigationLink {
                        LectureDetailList()
                    } label: {
                        EmptyView()
                    }
                    // workarounds to hide arrow indicator
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                    
                    TimetableListCell()
                }
            }
        }.listStyle(GroupedListStyle())
    }
}

struct TimetableList_Previews: PreviewProvider {
    static var previews: some View {
        TimetableList()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
    }
}
