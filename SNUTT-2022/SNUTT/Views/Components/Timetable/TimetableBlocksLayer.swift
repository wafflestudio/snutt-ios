//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlocksLayer: View {
    let current: Timetable?
    let config: TimetableConfiguration

    var currentTheme: Theme {
        current?.theme ?? .snutt
    }

    var body: some View {
        ForEach(current?.lectures ?? []) { lecture in
            LectureBlocks(current: current, lecture: lecture, theme: currentTheme, config: config)
        }

        if var selectedLecture = current?.selectedLecture {
            LectureBlocks(current: current, lecture: selectedLecture.withTemporaryColor(), theme: currentTheme, config: config)
        }

        let _ = debugChanges()
    }
}

// struct TimetableBlocks_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            let viewModel = TimetableViewModel(container: .preview)
//            TimetableBlocksLayer(viewModel: .init(container: .preview))
//                .environmentObject(viewModel.timetableState)
//        }
//    }
// }
