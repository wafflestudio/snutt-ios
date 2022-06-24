//
//  LectureList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import SwiftUI

struct LectureList: View {
    let lectures: [Lecture]

    var body: some View {
        List(lectures) { lecture in
            ZStack {
                NavigationLink {
                    LectureDetails()
                } label: {
                    EmptyView()
                }
                // workaround to hide arrow indicator
                .opacity(0.0)

                LectureListCell(lecture: lecture)
            }
        }.listStyle(PlainListStyle())
        
        let _ = debugChanges()
    }
}

struct TimetableList_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        
        NavigationView {
            LectureList(lectures: appState.currentTimetable.lectures)
        }
    }
}
