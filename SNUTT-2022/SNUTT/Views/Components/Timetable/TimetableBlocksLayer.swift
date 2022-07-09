//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlocksLayer: View {
    @EnvironmentObject var currentTimetable: Timetable

    var body: some View {
        ForEach(currentTimetable.lectures) { lecture in
            LectureBlocks(lecture: lecture)
        }

        let _ = debugChanges()
    }
}

//struct TimetableBlocks_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            let viewModel = TimetableViewModel(appState: AppState())
//            TimetableBlocksLayer()
//                .environmentObject(viewModel.currentTimetable)
//                .environmentObject(viewModel.timetableSetting)
//        }
//    }
//}
