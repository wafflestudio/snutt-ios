//
//  TimetableList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import SwiftUI

struct TimetableList: View {
    @EnvironmentObject var appState: AppState
    var lectures: [Lecture]

    var body: some View {
        List(lectures) { lecture in
            ZStack {
                NavigationLink {
                    LectureDetails().onAppear {
                        appState.system.showActivityIndicator = !appState.system.showActivityIndicator
                    }
                } label: {
                    EmptyView()
                }
                // workarounds to hide arrow indicator
                .opacity(0.0)

                TimetableListCell(lecture: lecture)
            }
        }
        .listStyle(GroupedListStyle())
    }
}

//
// struct TimetableList_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            TimetableList(lectures: AppState().currentTimetable.lectures)
//        }
//    }
// }
