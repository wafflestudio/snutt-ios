//
//  TimetableList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import SwiftUI

struct TimetableList: View {
    
    let lectures : [Lecture]
    
    var body: some View {
        List(lectures) { lecture in
            ZStack {
                NavigationLink {
                    LectureDetails()
                } label: {
                    EmptyView()
                }
                // workarounds to hide arrow indicator
                .opacity(0.0)

                TimetableListCell(lecture: lecture)
            }
        }.listStyle(GroupedListStyle())
    }
}

struct TimetableList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimetableList(lectures: DummyAppState.shared.lectures)
        }
    }
}
