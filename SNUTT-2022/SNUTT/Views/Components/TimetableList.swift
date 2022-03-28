//
//  TimetableList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import SwiftUI

struct TimetableList: View {
    var body: some View {
        List {
            ForEach(1 ..< 10) { _ in
                ZStack {
                    NavigationLink {
                        LectureDetails()
                    } label: {
                        EmptyView()
                    }
                    // workarounds to hide arrow indicator
                    .opacity(0.0)

                    TimetableListCell()
                }
            }
        }.listStyle(GroupedListStyle())
    }
}

struct TimetableList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimetableList()
        }
    }
}
