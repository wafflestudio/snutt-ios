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
    @Environment(\.selectedLecture) var selectedLecture: Lecture?
    
    var currentTheme: Theme {
        current?.theme ?? .snutt
    }

    var body: some View {
        ForEach(current?.lectures ?? []) { lecture in
            LectureBlocks(lecture: lecture, theme: currentTheme, config: config)
        }
        
        if var selectedLecture = selectedLecture {
            let _ = print("selected!")
            LectureBlocks(lecture: selectedLecture.withTemporaryColor(), theme: currentTheme, config: config)
        }

        let _ = debugChanges()
    }
}

extension TimetableBlocksLayer {
    class ViewModel: BaseViewModel {
        var lectures: [Lecture] {
            appState.timetable.current?.lectures ?? []
        }
    }
}

//struct TimetableBlocks_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            let viewModel = TimetableViewModel(container: .preview)
//            TimetableBlocksLayer(viewModel: .init(container: .preview))
//                .environmentObject(viewModel.timetableState)
//        }
//    }
//}
