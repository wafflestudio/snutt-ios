//
//  TimetableList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import SwiftUI

struct TimetableList: View {
    @ObservedObject var viewModel: TimetableViewModel

    var body: some View {
        List(viewModel.lectures) { lecture in
            ZStack {
                NavigationLink {
                    // for test(remove and implement otherwise)
                    LectureDetails(lecture: lecture).onAppear {
                        viewModel.update()
                    }
                } label: {
                    EmptyView()
                }
                // workarounds to hide arrow indicator
                .opacity(0.0)

                // for test(remove and implement otherwise)
                TimetableListCell(lecture: lecture).foregroundColor(viewModel.appState.system.showActivityIndicator ? .yellow : .gray)
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
