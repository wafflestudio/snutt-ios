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
    
    #if !WIDGET
    @Environment(\.selectedLecture) var selectedLecture: Lecture?
    #endif
    
    var currentTheme: Theme {
        current?.theme ?? .snutt
    }

    var body: some View {
        ForEach(current?.lectures ?? []) { lecture in
            LectureBlocks(lecture: lecture, theme: currentTheme, config: config)
        }
        
        #if !WIDGET
        if var selectedLecture = selectedLecture {
            let _ = print("selected!")
            LectureBlocks(lecture: selectedLecture.withTemporaryColor(), theme: currentTheme, config: config)
        }
        #endif

        let _ = debugChanges()
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
